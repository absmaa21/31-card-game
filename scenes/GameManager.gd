extends Node
class_name GameManager

const MULTIPLAYER_MENU: PackedScene = preload("uid://dbwnmtcemd8h7")
const LOBBY_MENU: PackedScene = preload("uid://brnkgd403v5xi")
const DIRECT_CONNECT_MENU = preload("uid://di1tj2dupr7f3")


signal scene_changed(type: SceneType)

enum SceneType {
	MAIN_MENU,
	LOBBY_LIST,
	IN_LOBBY,
	DIRECT_CONNECT,
	IN_GAME
}

@onready var current_scene: Node = $CurrentScene


func _ready() -> void:
	Glob.game_manager = self
	change_scene(SceneType.LOBBY_LIST)
	Glob.lobby_manager.lobby_created.connect(_on_lobby_created)
	Glob.lobby_manager.lobby_joined.connect(_on_lobby_joined)
	Glob.lobby_manager.lobby_left.connect(_on_lobby_left)


@rpc("call_local")
func change_scene(type: SceneType) -> void:
	print("Trying to change scene to: %s" % type)

	var packed_scene: PackedScene = get_scene_by_type(type)
	if not packed_scene: return
	var new_scene: Node = packed_scene.instantiate()

	for child: Node in current_scene.get_children():
		child.queue_free()

	current_scene.add_child(new_scene)
	scene_changed.emit(type)


func get_scene_by_type(type: SceneType) -> PackedScene:
	match type:
		SceneType.LOBBY_LIST: return MULTIPLAYER_MENU
		SceneType.IN_LOBBY: return LOBBY_MENU
		SceneType.DIRECT_CONNECT: return DIRECT_CONNECT_MENU

	push_warning("SceneType %d has no PackedScene connected!" % type)
	return null


func _on_lobby_created() -> void:
	change_scene(SceneType.IN_LOBBY)
	Glob.lobby_manager.set_lobby_data("secret", "7aa0acee-d944-4219-977d-54697e7c0431")
	Glob.lobby_manager.set_lobby_data("lobby_name", "%s's Lobby" % Glob.player_data.username)
	Glob.lobby_manager.set_lobby_data("game_mode", "31 Cards")
	Glob.lobby_manager.set_lobby_data("max_players", str(Glob.lobby_manager.lobby_members_max))

func _on_lobby_joined() -> void:
	change_scene(SceneType.IN_LOBBY)

func _on_lobby_left() -> void:
	change_scene(SceneType.LOBBY_LIST)
