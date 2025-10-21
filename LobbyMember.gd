extends Resource
class_name LobbyMember

var id: int
var username: String


func _init(_id: int, _username: String) -> void:
	id = _id
	username = _username
