extends Node

var game_manager: GameManager
var lobby_manager: LobbyManager

func _ready() -> void:
	if OS.has_feature("steam"):
		lobby_manager = SteamLobbyManager.new()
	else:
		lobby_manager = GodotLobbyManager.new()
