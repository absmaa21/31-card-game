extends Interactable
class_name Button3D

@export var text: String
@onready var button: Button = $Sprite3D/SubViewport/Button


func _ready() -> void:
	button.text = text
	button.disabled = true


func interact() -> void:
	button.pressed.emit()


func _on_is_hovered_changed() -> void:
	button.disabled = not is_hovered
