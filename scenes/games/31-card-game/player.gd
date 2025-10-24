extends CharacterBody3D
class_name Player31CardGame


@export var corresponding_id: int:
	set(value):
		corresponding_id = value
		input_sync.set_multiplayer_authority(corresponding_id)

var base_rot_y: float = 0

@onready var anim_player: AnimationPlayer = $"Barbarian/AnimationPlayer"
@onready var camera: Camera3D = $Camera3D
@onready var barbarian: Node3D = $Barbarian
@onready var input_sync: InputSynchronizer = $InputSynchronizer


func _ready() -> void:
	corresponding_id = int(name)
	anim_player.play("Sit_Chair_Pose")
	if corresponding_id == multiplayer.get_unique_id():
		camera.make_current()
		barbarian.visible = false
