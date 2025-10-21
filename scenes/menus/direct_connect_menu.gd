extends CanvasLayer
class_name DirectConnect


@onready var text_edit: TextEdit = %TextEdit
@onready var error_message: RichTextLabel = %ErrorMessage
@onready var submit_button: Button = %SubmitButton
@onready var cancel_button: Button = %CancelButton


func _ready() -> void:
	text_edit.text = ""
	submit_button.pressed.connect(_on_submit_button_pressed)
	text_edit.text_changed.connect(_on_input_text_changed)
	cancel_button.pressed.connect(_on_cancel_pressed)


func _on_submit_button_pressed() -> void:
	if text_edit.text.split(".").size() != 4:
		error_message.text = "Ip format is invalid!"
		return

	Glob.lobby_manager.join_lobby(randi(), text_edit.text)


func _on_input_text_changed() -> void:
	error_message.text = ""


func _on_cancel_pressed() -> void:
	Glob.game_manager.change_scene(GameManager.SceneType.LOBBY_LIST)
