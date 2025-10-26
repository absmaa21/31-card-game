extends RigidBody3D
class_name Card

signal change

enum Symbol {SPADE, HEART, DIAMOND, CLUB}
enum FaceImage {TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, JACK, QUEEN, KING, ACE}

var symbol: Symbol
var face: FaceImage

@onready var front: MeshInstance3D = $Front


func _to_string() -> String:
	return "%s %s" % [Symbol.keys()[symbol], FaceImage.keys()[face]]


func get_card_texture(card: Card = self) -> CompressedTexture2D:
	var face_str: String = FaceImage.keys()[card.face]
	face_str = face_str.capitalize()
	var symbol_str: String = Symbol.keys()[card.symbol]
	symbol_str = symbol_str.capitalize()
	return load("res://assets/playing-cards/%s/%s_%s.png" % [Settings.card_color, symbol_str, face_str])


@rpc
func _sync(new_symbol: Symbol, new_face: FaceImage) -> void:
	symbol = new_symbol
	face = new_face
