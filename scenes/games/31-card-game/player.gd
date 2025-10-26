extends CharacterBody3D
class_name Player31CardGame


@export var corresponding_id: int
@export var base_rot_y: float = 0
@export var lives: int = 3

var spawn_point: Marker3D
var free_cam_active: bool = false

@onready var anim_player: AnimationPlayer = $"Barbarian/AnimationPlayer"
@onready var camera: Camera3D = $Camera3D
@onready var barbarian: Node3D = $Barbarian
@onready var input_sync: InputSynchronizer = $InputSynchronizer
@onready var card_hand: CardHand = $CardHand


func _ready() -> void:
	corresponding_id = int(name)
	anim_player.play("Sit_Chair_Pose")
	if corresponding_id == multiplayer.get_unique_id():
		camera.make_current()
		barbarian.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
