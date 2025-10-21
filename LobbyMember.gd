extends Resource
class_name LobbyMember

var steam_id: int
var steam_name: String


func _init(_steam_id: int, _steam_name: String) -> void:
	steam_id = _steam_id
	steam_name = _steam_name
