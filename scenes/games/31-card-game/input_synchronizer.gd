extends MultiplayerSynchronizer
class_name InputSynchronizer

@export var player: Player31CardGame


func _ready() -> void:
	get_window().focus_entered.connect(func() -> void:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)
	get_window().focus_exited.connect(func() -> void:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	)


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return

	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	player.camera.rotation.y = clampf(
		player.camera.rotation.y - event.screen_relative.x * 0.001,
		player.base_rot_y - deg_to_rad(45),
		player.base_rot_y + deg_to_rad(45)
	)
	player.camera.rotation.x = clampf(
		player.camera.rotation.x - event.screen_relative.y * 0.001,
		deg_to_rad(-45),
		deg_to_rad(30)
	)
