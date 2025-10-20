extends CanvasLayer
class_name MultiplayerMenu


const LOBBY_BUTTON = preload("uid://mhkxfrdxhprx")

@onready var lobby_list: VBoxContainer = $CenterContainer/LobbyList


func _ready() -> void:
	Steam.lobby_match_list.connect(_on_lobby_match_list)


func _on_lobby_match_list(these_lobbies: Array) -> void:
	for child: Node in lobby_list.get_children():
		child.queue_free()

	for this_lobby in these_lobbies:
		# todo check if this_lobby is just an id -> int
		print(this_lobby)
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var lobby_max_players: int = int(Steam.getLobbyData(this_lobby, "max_players"))

		var button: LobbyButton = LOBBY_BUTTON.instantiate()
		button.lobby_name.text = lobby_name
		button.lobby_mode.text = lobby_mode
		button.player_count.text = "%d / %d" % [lobby_num_members, lobby_max_players]

		lobby_list.add_child(button)
