@abstract
extends Area3D
class_name Interactable

var is_hovered: bool = false:
	set(value):
		is_hovered = value
		_on_is_hovered_changed()


@abstract
func interact() -> void

@abstract
func _on_is_hovered_changed() -> void
