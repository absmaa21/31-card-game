extends Node
class_name GameManager

const SPLASH = preload("uid://dcr6afgf5eafc")
const MULTIPLAYER_MENU: PackedScene = preload("uid://dbwnmtcemd8h7")
const LOBBY_MENU: PackedScene = preload("uid://brnkgd403v5xi")

signal scene_changed(type: SceneType)

enum SceneType {
	SPLASH,
	LOBBY_LIST,
	LOBBY,
	GAME
}

@onready var current_scene: Node = $CurrentScene


func _ready() -> void:
	Glob.game_manager = self
	change_scene(SceneType.LOBBY_LIST)


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
		SceneType.SPLASH: return SPLASH
		SceneType.LOBBY_LIST: return MULTIPLAYER_MENU
		SceneType.LOBBY: return LOBBY_MENU

	push_warning("SceneType %d has no PackedScene connected!" % type)
	return null
