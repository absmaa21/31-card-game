extends Interactable
class_name Card

signal change

enum Symbol {SPADE, HEART, DIAMOND, CLUB}
enum FaceImage {TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, JACK, QUEEN, KING, ACE}

var hand: CardHand
var is_placeholder: bool = true
var symbol: Symbol
var face: FaceImage
var selected: bool = false:
	set(value):
		selected = value
		arrow.visible = selected

@onready var front: MeshInstance3D = $Front
@onready var arrow: MeshInstance3D = $Arrow


func _ready() -> void:
	hand = get_parent().get_parent()
	arrow.visible = false


func _to_string() -> String:
	return "%s %s" % [Symbol.keys()[symbol], FaceImage.keys()[face]]
 

func get_card_texture(card: Card = self) -> CompressedTexture2D:
	if is_placeholder: return null
	var face_str: String = FaceImage.keys()[card.face]
	face_str = face_str.capitalize()
	var symbol_str: String = Symbol.keys()[card.symbol]
	symbol_str = symbol_str.capitalize()
	return load("res://assets/playing-cards/%s/%s_%s.png" % [Settings.card_color, symbol_str, face_str])


@rpc
func _sync(new_symbol: Symbol, new_face: FaceImage) -> void:
	symbol = new_symbol
	face = new_face


func _on_is_hovered_changed() -> void:
	var mesh: PlaneMesh = front.mesh
	(mesh.material as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if is_hovered else BaseMaterial3D.SHADING_MODE_PER_PIXEL


func interact() -> void:
	var prev_value: bool = selected
	hand.unselect_all_cards()
	selected = not prev_value
