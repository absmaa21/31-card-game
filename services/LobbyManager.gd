extends Node

signal lobby_members_updated(members: Array[LobbyMember])

var lobby_id: int = 0:
	set(value):
		lobby_id = value
		Glob.game_manager.change_scene(GameManager.SceneType.LOBBY if lobby_id > 0 else GameManager.SceneType.LOBBY_LIST)
		get_lobby_members()
var lobby_members: Array[LobbyMember] = []
var lobby_members_max: int = 8
var lobby_vote_kick: bool = false


func _ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.persona_state_change.connect(_on_persona_change)
	Steam.lobby_chat_update.connect(_on_lobby_update)

	check_join_via_command_line()


func _process(_delta: float) -> void:
	# Cannot be done via Project Settings at the moment (20.10.2025)
	Steam.run_callbacks()


## This is important if the player is accepting a Steam invite or Joins the Game via the friends list and doesn't have the game open.
func check_join_via_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	if these_arguments.size() <= 0: return
	if these_arguments[0] != "+connect_lobby": return
	if int(these_arguments[1]) <= 0: return

	print("Command line lobby ID: %s" % these_arguments[1])
	join_lobby(int(these_arguments[1]))


func create_lobby() -> void:
	if lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, lobby_members_max)


func join_lobby(this_lobby_id: int) -> void:
	print_debug("Attempting to join lobby %s" % this_lobby_id)
	lobby_members.clear()
	Steam.joinLobby(this_lobby_id)


func leave_lobby() -> void:
	if lobby_id <= 0:
		print_debug("Cannot leave a lobby if player is in no lobby")
		return

	Steam.leaveLobby(lobby_id)
	lobby_id = 0
	for this_member: LobbyMember in lobby_members:
		if this_member.steam_id != Steam.getSteamID():
			Steam.closeP2PSessionWithUser(this_member.steam_id)
	lobby_members.clear()


func request_lobby_list() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func get_lobby_members() -> Array[LobbyMember]:
	lobby_members.clear()
	if lobby_id <= 0: return []

	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
	for index: int in range(num_of_members):
		var steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, index)
		var steam_name: String = Steam.getFriendPersonaName(steam_id)
		lobby_members.append(LobbyMember.new(steam_id, steam_name))

	lobby_members_updated.emit(lobby_members)
	return lobby_members


func make_p2p_handshake() -> void:
	print_debug("Sending P2P handshake to the lobby ...")
	var lobby_owner_id: int = Steam.getLobbyOwner(lobby_id)
	Steam.sendP2PPacket(lobby_owner_id, ['handshake'], Steam.P2PSend.P2P_SEND_RELIABLE)


func _on_lobby_created(connection: int, this_lobby_id: int) -> void:
	if connection != 1: return
	lobby_id = this_lobby_id
	print("Created a lobby: %s" % lobby_id)

	# Should be done by default, but just in case
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyData(lobby_id, "name", "my lobby")
	Steam.setLobbyData(lobby_id, "mode", "31 Cards")
	Steam.setLobbyData(lobby_id, "max_players", str(lobby_members_max))

	# Allow P2P connections to fallback to being relayed through Steam if needed
	var set_relay: bool = Steam.allowP2PPacketRelay(true)
	print_debug("Allowing Steam to be relay backup: %s" % set_relay)


func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = this_lobby_id
		make_p2p_handshake()

	else:
		var fail_reason: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
		
		print("Failed to join lobby: %s" % fail_reason)


func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	var owner_name: String = Steam.getFriendPersonaName(friend_id)
	print_debug("Joining %s's lobby ..." % owner_name)
	join_lobby(this_lobby_id)


func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	if lobby_id <= 0: return
	print_debug("A user (%s) had information change. Update the lobby members ..." % this_steam_id)
	get_lobby_members()


func _on_lobby_update(_this_lobby_id: int, change_id: int, _making_change_id: int, changer_state: int) -> void:
	var changer_name: String = Steam.getFriendPersonaName(change_id)

	match changer_state:
		Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED: print("%s has joined the lobby." % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_LEFT: print("%s has left the lobby" % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_KICKED: print("%s has been kicked from the lobby" % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_BANNED: print("%s has been banned from the lobby" % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED: print("%s has closed the game" % changer_name)
		_: print_debug("%s did... something (%d)" % [changer_name, changer_state])

	get_lobby_members()
