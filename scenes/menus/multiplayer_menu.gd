extends CanvasLayer
class_name MultiplayerMenu


const LOBBY_BUTTON = preload("uid://mhkxfrdxhprx")

@onready var lobby_list: VBoxContainer = %LobbyList
@onready var lobby_count: RichTextLabel = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/LobbyCount
@onready var create_lobby_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/CreateLobbyButton
@onready var lobby_list_interval: Timer = $LobbyListInterval


func _ready() -> void:
	LobbyManager.request_lobby_list()
	lobby_count.text = "No lobbies found"

	lobby_list_interval.timeout.connect(LobbyManager.request_lobby_list)
	create_lobby_button.pressed.connect(LobbyManager.create_lobby)
	Steam.lobby_match_list.connect(_on_lobby_match_list)


func _on_lobby_match_list(these_lobbies: Array) -> void:
	for child: Node in lobby_list.get_children():
		child.queue_free()

	for this_lobby: int in these_lobbies:
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var lobby_max_players: int = int(Steam.getLobbyData(this_lobby, "max_players"))

		var button: LobbyButton = LOBBY_BUTTON.instantiate()
		lobby_list.add_child(button)
		button.lobby_id = this_lobby
		button.lobby_name.text = lobby_name
		button.lobby_mode.text = lobby_mode
		button.player_count.text = "%d / %d" % [lobby_num_members, lobby_max_players]

	lobby_count.text = "%d lobbies found" % these_lobbies.size()
