extends Area3D
class_name Button3D

@onready var button: Button = $Sprite3D/SubViewport/Button

@export var text: String


func _ready() -> void:
	button.text = text
	button.disabled = true


func set_hover(value: bool) -> void:
	button.disabled = not value
