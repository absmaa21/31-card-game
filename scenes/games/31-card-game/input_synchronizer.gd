extends MultiplayerSynchronizer
class_name InputSynchronizer

@export var player: Player31CardGame


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return

	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)

	elif event.is_action_pressed("interact"):
		if player.cur_interactable:
			player.cur_interactable.interact()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	player.camera.rotation.y = clampf(
		player.camera.rotation.y - event.screen_relative.x * 0.001 * Settings.sensitivity,
		player.base_rot_y - deg_to_rad(45),
		player.base_rot_y + deg_to_rad(45)
	)
	player.camera.rotation.x = clampf(
		player.camera.rotation.x - event.screen_relative.y * 0.001 * Settings.sensitivity,
		deg_to_rad(-45),
		deg_to_rad(30)
	)


func _physics_process(_delta: float) -> void:
	if not player.game.player_id_can_do_smth(multiplayer.get_unique_id()): return
	if player.ray_cast.get_collider() is Interactable:
		player.cur_interactable = player.ray_cast.get_collider()
	else:
		player.cur_interactable = null


func toggle_card(card: Card, value: bool) -> void:
	var mesh: PlaneMesh = card.front.mesh
	(mesh.material as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if value else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	player.currently_looked_at_card = card if value else null
