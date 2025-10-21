@abstract
extends Node
class_name LobbyManager

signal lobby_data_updated(key: String, value: String)
signal lobby_members_updated(members: Array[LobbyMember])

var lobby_id: int = 0:
	set(value):
		lobby_id = value
		Glob.game_manager.change_scene(GameManager.SceneType.LOBBY if is_lobby_id_valid() else GameManager.SceneType.LOBBY_LIST)
		refresh_lobby_members()
var lobby_members: Array[LobbyMember] = []
var lobby_members_max: int = 8


@abstract
func create_lobby() -> void

@abstract
func join_lobby(id: int, ip_address: String) -> void

@abstract
func leave_lobby() -> void

@abstract
func request_lobby_list() -> void

@abstract
func refresh_lobby_members() -> void

@abstract
func get_lobby_data(key: String) -> String

@abstract
func set_lobby_data(key: String, value: String)

func is_lobby_id_valid(this_lobby_id: int = lobby_id, check_via_network: bool = false) -> bool:
	if check_via_network:
		return this_lobby_id > 0
	return this_lobby_id > 0
