extends Node3D
class_name CardHand

const CARD = preload("uid://b0q72fruoa26k")

var spacing: float = 0
var origin_pos: Vector3
var origin_rot: Vector3

var cards: Dictionary[int, Card] = {
	0: null,
	1: null,
	2: null,
}

@onready var cards_node: Node3D = $Cards


func _ready() -> void:
	origin_pos = position
	origin_rot = rotation
	for child: Node3D in cards_node.get_children():
		if child.position.x > spacing: spacing = child.position.x
		child.queue_free()


## Switches the card of one [class CardHand] with another
func switch_cards(other: CardHand, self_index: int, other_index: int) -> void:
	var self_card: Card = self.cards.get(self_index)
	var other_card: Card = other.cards.get(other_index)
	self.cards.set(self_index, other_card)
	other.cards.set(other_index, self_card)
	_refresh_card(self_index)


func _on_cur_player_turn_changed(id: int) -> void:
	print("%d - %d" % [id, multiplayer.get_unique_id()])
	if id == multiplayer.get_unique_id():
		position.y = 1.2
		rotation.x = 45

	else:
		position = origin_pos
		rotation = origin_rot


func _to_string() -> String:
	var string: String = ""
	for key: int in cards.keys():
		var card: Card = cards.get(key)
		if card: string += "card%d(%s) " % [key, card.to_string()]
	return string


func _refresh_card(index: int) -> void:
	var card: Card = cards.get(index)
	if card.get_parent() == null:
		cards_node.add_child(card, true)
	if index == 0: card.position.x = -spacing
	elif index == 1: card.position.x = 0
	else: card.position.x = spacing
	var texture: CompressedTexture2D = card.get_card_texture()
	var mesh: PlaneMesh = card.front.mesh.duplicate_deep()
	(mesh.material as StandardMaterial3D).albedo_texture = texture
	card.front.mesh = mesh


@rpc
func _sync_card(index: int, face: Card.FaceImage, symbol: Card.Symbol) -> void:
	var new_card: Card = CARD.instantiate()
	new_card.face = face
	new_card.symbol = symbol
	cards.set(index, new_card)
	_refresh_card(index)
