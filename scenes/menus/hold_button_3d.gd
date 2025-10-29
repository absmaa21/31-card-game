extends Interactable
class_name HoldButton3D

const TIMER_SEC: float = 1.5

var timeout_method: Callable

@onready var progress_bar: ProgressBar = $Sprite3D/SubViewport/HoldButton/ProgressBar
@onready var button: Button = $Sprite3D/SubViewport/HoldButton/Button
@onready var interact_timer: Timer = $Sprite3D/SubViewport/HoldButton/InteractTimer


func _ready() -> void:
	set_process(false)
	progress_bar.value = 0
	_on_is_hovered_changed()


func _process(_delta: float) -> void:
	progress_bar.value = (TIMER_SEC - interact_timer.time_left) / TIMER_SEC * 100


func interact() -> void:
	set_process(true)
	interact_timer.start(TIMER_SEC)
	button.button_pressed = true


func cancel() -> void:
	set_process(false)
	interact_timer.stop()
	button.button_pressed = false


func _on_is_hovered_changed() -> void:
	button.disabled = not is_hovered
	if not is_hovered:
		cancel()


func _on_interact_timeout() -> void:
	if timeout_method: timeout_method.call()
	else: push_warning("No 'timeout_method' set for HoldButton3D '%s'" % name)
