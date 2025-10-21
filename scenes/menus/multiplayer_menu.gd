extends CanvasLayer
class_name MultiplayerMenu


const LOBBY_BUTTON = preload("uid://mhkxfrdxhprx")

@onready var lobby_list: VBoxContainer = %LobbyList
@onready var lobby_count: RichTextLabel = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/LobbyCount
@onready var create_lobby_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/CreateLobbyButton
@onready var lobby_list_interval: Timer = $LobbyListInterval


func _ready() -> void:
	Glob.lobby_manager.request_lobby_list()
	lobby_count.text = "No lobbies found"

	lobby_list_interval.timeout.connect(Glob.lobby_manager.request_lobby_list)
	create_lobby_button.pressed.connect(Glob.lobby_manager.create_lobby)
	Steam.lobby_match_list.connect(_on_lobby_match_list)


func _on_lobby_match_list(these_lobbies: Array) -> void:
	for child: Node in lobby_list.get_children():
		child.queue_free()

	var invalid_lobbies: int = 0
	for this_lobby: int in these_lobbies:
		var lobby_data: Dictionary = Steam.getAllLobbyData(this_lobby)
		if not lobby_data.has_all(["name", "mode", "max_players"]):
			invalid_lobbies += 1
			continue

		var lobby_name: String = lobby_data.get("name")
		var lobby_mode: String = lobby_data.get("mode")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var lobby_max_players: int = int(lobby_data.get("max_players"))

		var button: LobbyButton = LOBBY_BUTTON.instantiate()
		lobby_list.add_child(button)
		button.lobby_id = this_lobby
		button.lobby_name.text = lobby_name
		button.lobby_mode.text = lobby_mode
		button.player_count.text = "%d / %d" % [lobby_num_members, lobby_max_players]

	print("Out of %d lobbies, %d were invalid" % [these_lobbies.size(), invalid_lobbies])
	if lobby_list.get_child_count() > 0:
		lobby_count.text = "%d lobbies found" % lobby_list.get_child_count()
	else:
		lobby_count.text = "No lobbies found"
