extends CharacterBody3D
class_name Player31CardGame


@export var corresponding_id: int:
	set(value):
		corresponding_id = value
		_on_corresponding_id_updated()

@onready var anim_player: AnimationPlayer = $"Barbarian/AnimationPlayer"
@onready var camera: Camera3D = $Camera3D
@onready var barbarian: Node3D = $Barbarian


func _ready() -> void:
	anim_player.play("Sit_Chair_Pose")
	corresponding_id = int(name)


func _on_corresponding_id_updated() -> void:
	if not is_node_ready(): return
	set_multiplayer_authority(corresponding_id)
	if is_multiplayer_authority():
		camera.make_current()
		barbarian.visible = false
