extends Node


var game_manager: GameManager
var lobby_manager: LobbyManager:
	set(value):
		lobby_manager = value
		lobby_manager.initialized.connect(_on_lobby_manager_initialized)
var player_data: LobbyMember


func _ready() -> void:
	_init_lobby_manager()


func _init_lobby_manager() -> void:
	if OS.has_feature("steam"): lobby_manager = SteamLobbyManager.new()
	else: lobby_manager = GodotLobbyManager.new()

	self.add_child(lobby_manager, true)


func _on_lobby_manager_initialized() -> void:
	if lobby_manager is SteamLobbyManager:
		player_data = LobbyMember.new(Steam.getSteamID(), Steam.getPersonaName())
	else:
		player_data = LobbyMember.new(multiplayer.get_unique_id(), "Anonymous Godot User")

	# Change scene to GameManager
	get_tree().change_scene_to_file.call_deferred("uid://bi4yflohrtu1r")
