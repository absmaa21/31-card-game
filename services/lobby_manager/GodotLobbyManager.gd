extends LobbyManager
class_name GodotLobbyManager


const PORT: int = 8812

var peer: MultiplayerPeer:
	set(value):
		peer = value
		multiplayer.multiplayer_peer = peer
var lobby_data: Dictionary[String, String] = {}


func _ready() -> void:
	name = "GodotLobbyManager"
	peer = ENetMultiplayerPeer.new()
	initialized.emit()


func create_lobby() -> void:
	if is_lobby_id_valid():
		push_warning("Cannot create a lobby if already connected to a lobby!")
		return
	peer.create_server(PORT, lobby_members_max)


func join_lobby(_id: int, ip_address: String) -> void:
	print_debug("Attempting to join lobby %s" % ip_address)
	lobby_members.clear()
	peer.create_client(ip_address, PORT)


func leave_lobby() -> void:
	if not is_lobby_id_valid():
		print_debug("Cannot leave a lobby if player is in no lobby")
		return

	peer.disconnect_peer(peer.get_unique_id())
	lobby_id = 0
	lobby_members.clear()
	lobby_data.clear()


func request_lobby_list() -> void:
	pass


func refresh_lobby_members() -> void:
	lobby_members.clear()
	if not is_lobby_id_valid(): return

	var connected_peers: Array[int] = multiplayer.get_peers()
	for id: int in connected_peers:
		lobby_members.append(LobbyMember.new(id, OS.get_name()))

	lobby_members_updated.emit(lobby_members)


func get_lobby_data(key: String) -> String:
	if not is_lobby_id_valid(): return ""
	return lobby_data.get(key)


func set_lobby_data(key: String, value: String) -> void:
	if not is_lobby_id_valid(): return
	lobby_data.set(key, value)
	_sync_lobby_data.rpc(key, value)


@rpc
func _sync_lobby_data(key: String, value: String) -> void:
	lobby_data.set(key, value)
