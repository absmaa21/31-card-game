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


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	if event.is_action_pressed("interact"):
		if currently_looked_at_card:
			print(currently_looked_at_card.to_string())
		elif currently_looked_at_btn:
			print("Pressed")


func _physics_process(_delta: float) -> void:
	if ray_cast.get_collider() is Card:
		if currently_looked_at_card: toggle_card(currently_looked_at_card, false)
		currently_looked_at_card = null
		toggle_card(ray_cast.get_collider(), true)
	elif currently_looked_at_card:
		toggle_card(currently_looked_at_card, false)

	if ray_cast.get_collider() is Button3D:
		if currently_looked_at_btn: currently_looked_at_btn.set_hover(false)
		currently_looked_at_btn = ray_cast.get_collider()
		currently_looked_at_btn.set_hover(true)
	elif currently_looked_at_btn:
		currently_looked_at_btn.set_hover(false)


func toggle_card(card: Card, value: bool) -> void:
	var mesh: PlaneMesh = card.front.mesh
	(mesh.material as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if value else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	currently_looked_at_card = card if value else null
