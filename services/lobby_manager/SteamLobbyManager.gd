extends LobbyManager
class_name SteamLobbyManager


func _ready() -> void:
	var init_response: Dictionary = Steam.steamInitEx(480, true)
	print("Steam Init response: %s " % init_response)
	if not init_response.has("verbal"):
		push_error("Response of Steam.steamInitEx has no field 'verbal'!")
		return

	if init_response.get("verbal") != "":
		if init_response.get("status") == 2:
			push_error("Steam is not open!")
		else:
			push_error("Error while initalizing steam: %s" % init_response.get("verbal"))
		return

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.persona_state_change.connect(_on_persona_change)
	Steam.lobby_chat_update.connect(_on_lobby_update)
	Steam.lobby_match_list.connect(lobby_match_list.emit)
	Steam.lobby_data_update.connect(_on_steam_lobby_data_update)

	name = "SteamLobbyManager"
	check_join_via_command_line()
	initialized.emit()


## This is important if the player is accepting a Steam invite or Joins the Game via the friends list and doesn't have the game open.
func check_join_via_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	if these_arguments.size() <= 0: return
	if these_arguments[0] != "+connect_lobby": return
	if int(these_arguments[1]) <= 0: return

	print("Command line lobby ID: %s" % these_arguments[1])
	join_lobby(int(these_arguments[1]))


func create_lobby() -> void:
	if is_lobby_id_valid():
		push_warning("Cannot create a lobby if already connected to a lobby!")
		return
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, lobby_members_max)


func join_lobby(id: int, _ip_address: String = "") -> void:
	print_debug("Attempting to join lobby %s" % id)
	lobby_members.clear()
	Steam.joinLobby(id)


func leave_lobby() -> void:
	if not is_lobby_id_valid():
		print_debug("Cannot leave a lobby if player is in no lobby")
		return

	Steam.leaveLobby(lobby_id)
	lobby_id = 0
	for this_member: LobbyMember in lobby_members:
		if this_member.steam_id != Steam.getSteamID():
			Steam.closeP2PSessionWithUser(this_member.steam_id)
	lobby_members.clear()
	lobby_left.emit()


func request_lobby_list() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("secret", "7aa0acee-d944-4219-977d-54697e7c0431", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


func refresh_lobby_members() -> void:
	lobby_members.clear()
	if not is_lobby_id_valid(): return

	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
	for index: int in range(num_of_members):
		var steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, index)
		var steam_name: String = Steam.getFriendPersonaName(steam_id)
		lobby_members.append(LobbyMember.new(steam_id, steam_name))

	lobby_members_updated.emit(lobby_members)


func make_p2p_handshake() -> void:
	print_debug("Sending P2P handshake to the lobby ...")
	var lobby_owner_id: int = Steam.getLobbyOwner(lobby_id)
	Steam.sendP2PPacket(lobby_owner_id, ['handshake'], Steam.P2PSend.P2P_SEND_RELIABLE)


func get_lobby_data(key: String) -> String:
	if not is_lobby_id_valid(): return ""
	return Steam.getLobbyData(lobby_id, key)


func set_lobby_data(key: String, value: String) -> void:
	if not is_lobby_id_valid(): return
	Steam.setLobbyData(lobby_id, key, value)


func get_all_lobby_data(id: int = lobby_id) -> Dictionary[String, String]:
	var raw_data: Dictionary = Steam.getAllLobbyData(id)
	var data: Dictionary[String, String] = {}
	for key: int in raw_data.keys():
		var key_data: Dictionary = raw_data.get(key)
		var data_key: String = key_data.get("key")
		var data_value: String = key_data.get("value")
		data.set(data_key, data_value)
	return data


func _on_lobby_created(connection: int, this_lobby_id: int) -> void:
	if connection != 1: return
	lobby_id = this_lobby_id
	print("Created a lobby: %s" % lobby_id)

	# Should be done by default, but just in case
	Steam.setLobbyJoinable(lobby_id, true)

	# Allow P2P connections to fallback to being relayed through Steam if needed
	var set_relay: bool = Steam.allowP2PPacketRelay(true)
	print_debug("Allowing Steam to be relay backup: %s" % set_relay)
	lobby_created.emit()


func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("Joined lobby %d" % this_lobby_id)
		lobby_id = this_lobby_id
		make_p2p_handshake()
		lobby_joined.emit()

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
	if not is_lobby_id_valid(): return
	print_debug("A user (%s) had information change. Update the lobby members ..." % this_steam_id)
	refresh_lobby_members()


func _on_lobby_update(_this_lobby_id: int, change_id: int, _making_change_id: int, changer_state: int) -> void:
	var changer_name: String = Steam.getFriendPersonaName(change_id)

	match changer_state:
		Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED: print("%s has joined the lobby." % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_LEFT: print("%s has left the lobby" % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_KICKED: print("%s has been kicked from the lobby" % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_BANNED: print("%s has been banned from the lobby" % changer_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED: print("%s has closed the game" % changer_name)
		_: print_debug("%s did... something (%d)" % [changer_name, changer_state])

	refresh_lobby_members()


func _on_steam_lobby_data_update(_success: int, _id: int, _member_id: int) -> void:
	var new_lobby_data: Dictionary = get_all_lobby_data()
	for key: String in new_lobby_data.keys():
		var value: String = new_lobby_data.get(key)
		if value != lobby_data.get(key):
			lobby_data.set(key, value)
			lobby_data_updated.emit(key, value)
