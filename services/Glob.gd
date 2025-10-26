extends Node


var game_manager: GameManager
var lobby_manager: LobbyManager:
	set(value):
		lobby_manager = value
		lobby_manager.initialized.connect(_on_lobby_manager_initialized)
var player_data: LobbyMember


func _ready() -> void:
	_init_lobby_manager()
	get_window().focus_entered.connect(func() -> void:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Glob.game_manager and Glob.game_manager.current_type == GameManager.SceneType.IN_GAME else Input.MOUSE_MODE_VISIBLE
	)
	get_window().focus_exited.connect(func() -> void:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _init_lobby_manager() -> void:
	if OS.has_feature("steam"):
		lobby_manager = SteamLobbyManager.new()
		print("Using GodotSteam with version %s" % Steam.get_godotsteam_version())
	else: lobby_manager = GodotLobbyManager.new()

	self.add_child(lobby_manager, true)


func _on_lobby_manager_initialized() -> void:
	if lobby_manager is SteamLobbyManager:
		player_data = LobbyMember.new(Steam.getSteamID(), Steam.getPersonaName())
	else:
		player_data = LobbyMember.new(0, "Anonymous Godot User")

	# Change scene to GameManager
	get_tree().change_scene_to_file.call_deferred("uid://bi4yflohrtu1r")
