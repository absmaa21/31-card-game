extends CharacterBody3D
class_name Player31CardGame


@export var corresponding_id: int
@export var base_rot_y: float = 0
@export var lives: int = 3
@export var spawn_point_path: NodePath:
	set(value):
		spawn_point_path = value
		if value: spawn_point = get_node(value)

var spawn_point: Marker3D
var currently_looked_at_card: Card
var currently_looked_at_btn: Button3D
var cur_interactable: Interactable:
	set(value):
		if cur_interactable: cur_interactable.is_hovered = false
		cur_interactable = value
		cur_interactable.is_hovered = true
var game: Game_31CardGame

@onready var anim_player: AnimationPlayer = $"Barbarian/AnimationPlayer"
@onready var camera: Camera3D = $Camera3D
@onready var barbarian: Node3D = $Barbarian
@onready var input_sync: InputSynchronizer = $InputSynchronizer
@onready var card_hand: CardHand = $CardHand
@onready var ray_cast: RayCast3D = $Camera3D/RayCast3D


func _ready() -> void:
	corresponding_id = int(name)
	anim_player.play("Sit_Chair_Pose")
	if corresponding_id == multiplayer.get_unique_id():
		camera.make_current()
		barbarian.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
