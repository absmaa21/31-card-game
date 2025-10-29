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
		if value == cur_interactable: return
		if cur_interactable: cur_interactable.is_hovered = false
		cur_interactable = value
		if cur_interactable: cur_interactable.is_hovered = true
var game: Game_31CardGame
var head_bone: int

@onready var anim_player: AnimationPlayer = $Model/AnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var model: Node3D = $Model
@onready var input_sync: InputSynchronizer = $InputSynchronizer
@onready var card_hand: CardHand = $CardHand
@onready var ray_cast: RayCast3D = $Camera3D/RayCast3D
@onready var skeleton: Skeleton3D = $Model/Root/GeneralSkeleton
@onready var turn_choices: Node3D = $TurnChoices


func _ready() -> void:
	corresponding_id = int(name)
	anim_player.play("Sitting Idle")
	head_bone = skeleton.find_bone("Head")
	turn_choices.visible = false
	MessageBus.current_player_turn_changed.connect(_on_cur_player_turn_changed)
	if corresponding_id == multiplayer.get_unique_id():
		camera.make_current()
		model.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		input_sync.set_physics_process(false)
		input_sync.set_process_input(false)


func _on_cur_player_turn_changed(id: int) -> void:
	turn_choices.visible = id == corresponding_id and id == multiplayer.get_unique_id()
	if id == multiplayer.get_unique_id():
		get_window().request_attention()
		get_window().grab_focus()


func _process(_delta: float) -> void:
	var cam_rot: Vector3 = camera.rotation
	cam_rot.x *= -1
	cam_rot.y += deg_to_rad(180)
	skeleton.set_bone_pose_rotation(head_bone, Quaternion.from_euler(cam_rot))
