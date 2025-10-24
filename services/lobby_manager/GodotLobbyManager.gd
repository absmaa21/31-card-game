extends LobbyManager
class_name GodotLobbyManager


const PORT: int = 8812

var peer: ENetMultiplayerPeer


func _ready() -> void:
	name = "GodotLobbyManager"
	initialized.emit()
	multiplayer.peer_connected.connect(_on_peer_connected)


func create_lobby() -> void:
	if is_lobby_id_valid():
		push_warning("Cannot create a lobby if already connected to a lobby!")
		return
	peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(PORT, lobby_members_max)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		Glob.player_data.id = peer.get_unique_id()
		lobby_id = randi()
		lobby_created.emit()
		return
	push_error("Error while lobby creation. Code %s" % err)


func join_lobby(_id: int, ip_address: String) -> void:
	print_debug("Attempting to join lobby %s" % ip_address)
	lobby_members.clear()
	peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(ip_address, PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		Glob.player_data.id = peer.get_unique_id()
		lobby_joined.emit()
		return
	push_error("Error while joining lobby %s. Code %s" % [ip_address, err])


func leave_lobby() -> void:
	multiplayer.multiplayer_peer.close()
	Glob.player_data.id = 0
	lobby_id = 0
	lobby_members.clear()
	lobby_data.clear()
	lobby_left.emit()


func request_lobby_list() -> void:
	pass


func refresh_lobby_members() -> void:
	lobby_members.clear()
	for id: int in multiplayer.get_peers():
		lobby_members.append(LobbyMember.new(id, str(id)))

	lobby_members_updated.emit(lobby_members)


func get_lobby_data(key: String) -> String:
	return lobby_data.get(key)


func set_lobby_data(key: String, value: String) -> void:
	_sync_lobby_data.rpc(key, value)


func get_all_lobby_data(_id: int) -> Dictionary[String, String]:
	return lobby_data


@rpc("call_local")
func _sync_lobby_data(key: String, value: String) -> void:
	lobby_data.set(key, value)
	lobby_data_updated.emit(key, value)


func _on_peer_connected(id: int) -> void:
	refresh_lobby_members()
	if not multiplayer.is_server(): return
	for key: String in lobby_data.keys():
		_sync_lobby_data.rpc_id(id, key, lobby_data.get(key))
