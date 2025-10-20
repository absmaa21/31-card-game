extends Node
class_name GameManager


const MULTIPLAYER_MENU = preload("uid://dbwnmtcemd8h7")

signal scene_changed(type: SceneType)

enum SceneType {
	LOBBY_LIST,
	LOBBY,
	GAME
}

@onready var current_scene: Node = $CurrentScene


func _ready() -> void:
	change_scene(SceneType.LOBBY_LIST)


func change_scene(type: SceneType) -> void:
	print_debug("Trying to change scene to: %s" % type)

	var new_scene: Node
	match type:
		SceneType.LOBBY_LIST: new_scene = MULTIPLAYER_MENU.instantiate()
		_: return

	for child: Node in current_scene.get_children():
		child.queue_free()

	current_scene.add_child(new_scene)
	scene_changed.emit(type)
