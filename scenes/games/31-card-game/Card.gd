extends Resource
class_name Card

enum Symbol {SPADE, HEART, DIAMOND, CLUB}
enum FaceImage {TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, JACK, QUEEN, KING, ACE}

var symbol: Symbol
var face: FaceImage


func _init(_symbol: Symbol, _face: FaceImage) -> void:
	symbol = _symbol
	face = _face

func _to_string() -> String:
	return "%s %s" % [Symbol.keys()[symbol], FaceImage.keys()[face]]
