@abstract
extends Node
class_name LobbyManager


signal lobby_created
signal lobby_joined
signal lobby_left
signal lobby_data_updated(key: String, value: String)
signal lobby_members_updated(members: Array[LobbyMember])
signal lobby_match_list(lobbies: Array)
signal initialized

var lobby_id: int = 0:
	set(value):
		lobby_id = value
		refresh_lobby_members()
var lobby_members: Array[LobbyMember] = []
var lobby_members_max: int = 8
var lobby_data: Dictionary[String, String] = {}


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

@abstract
func get_all_lobby_data() -> Dictionary[String, String]

func is_lobby_id_valid(this_lobby_id: int = lobby_id, check_via_network: bool = false) -> bool:
	if check_via_network:
		push_warning("check_via_network part is not set. Override the method!")
	return this_lobby_id > 0
