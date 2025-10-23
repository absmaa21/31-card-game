extends CanvasLayer
class_name MultiplayerMenu


const USE_LOBBY_CHECK: bool = false
const LOBBY_BUTTON: PackedScene = preload("uid://mhkxfrdxhprx")

@onready var lobby_list: VBoxContainer = %LobbyList
@onready var lobby_count: RichTextLabel = %LobbyCount
@onready var create_lobby_button: Button = %CreateLobbyButton
@onready var lobby_list_interval: Timer = $LobbyListInterval
@onready var direct_connect: Button = %DirectConnect


func _ready() -> void:
	Glob.lobby_manager.request_lobby_list()
	lobby_count.text = "No lobbies found"

	lobby_list_interval.timeout.connect(Glob.lobby_manager.request_lobby_list)
	create_lobby_button.pressed.connect(Glob.lobby_manager.create_lobby)
	direct_connect.pressed.connect(_direct_connect_pressed)
	Glob.lobby_manager.lobby_match_list.connect(_on_lobby_match_list)

	if Glob.lobby_manager is SteamLobbyManager:
		direct_connect.queue_free()


func _on_lobby_match_list(these_lobbies: Array) -> void:
	for child: Node in lobby_list.get_children():
		child.queue_free()

	var invalid_lobbies: int = 0
	for this_lobby: int in these_lobbies:
		var lobby_data: Dictionary = Glob.lobby_manager.get_all_lobby_data(this_lobby)
		if USE_LOBBY_CHECK and not lobby_data.has_all(["lobby_name", "game_mode", "max_players"]):
			invalid_lobbies += 1
			continue

		var lobby_name: String = lobby_data.get("lobby_name", "")
		var lobby_mode: String = lobby_data.get("game_mode", "")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var lobby_max_players: int = int(lobby_data.get("max_players", "0"))

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


func _direct_connect_pressed() -> void:
	Glob.game_manager.change_scene(GameManager.SceneType.DIRECT_CONNECT)
