extends Node

var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 8
var lobby_vote_kick: bool = false


func _ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)

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


func open_lobby_list() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


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
