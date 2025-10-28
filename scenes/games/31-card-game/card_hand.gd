extends Node3D
class_name CardHand

const CARD = preload("uid://b0q72fruoa26k")

const SPACING: float = 0.25
@export var parent: Player31CardGame

var cards: Dictionary[int, Card] = {
	0: null,
	1: null,
	2: null,
}

@onready var cards_node: Node3D = $Cards


func _ready() -> void:
	MessageBus.current_player_turn_changed.connect(_on_cur_player_turn_changed)
	for i: int in range(3):
		set_card(i, cards_node.get_child(i))


func remove_card(index: int) -> Card:
	var card: Card = cards.get(index)
	if card and card.get_parent():
		cards.set(index, null)
		card.get_parent().remove_child(card)
	return card


func set_card(index: int, card: Card) -> void:
	var old_card: Card = cards.get(index)
	if old_card and old_card.get_parent(): old_card.get_parent().remove_child(old_card)
	cards.set(index, card)
	_refresh_card(index)


## Switches the card of one [class CardHand] with another
func switch_cards(other: CardHand, self_index: int, other_index: int) -> void:
	var self_card: Card = self.remove_card(self_index)
	var other_card: Card = other.remove_card(other_index)
	set_card(self_index, self_card)
	other.set_card(other_index, other_card)


func _on_cur_player_turn_changed(id: int) -> void:
	if not parent: return
	if id == multiplayer.get_unique_id():
		global_position.y = parent.spawn_point.get_child(0).global_position.y + 0.2
		rotation.x = 45

	else:
		global_position = parent.spawn_point.get_child(0).global_position
		global_rotation = parent.spawn_point.get_child(0).global_rotation


func _to_string() -> String:
	var string: String = ""
	for key: int in cards.keys():
		var card: Card = cards.get(key)
		string += "card%d(%s) " % [key, card.to_string() if card else "null"]
	return string


func _refresh_card(index: int) -> void:
	var card: Card = cards.get(index)
	if card.get_parent() == null:
		cards_node.add_child(card, true)
	elif card.get_parent() != cards_node:
		card.reparent(cards_node, false)

	if index == 0: card.position.x = -SPACING
	elif index == 1: card.position.x = 0
	else: card.position.x = SPACING

	var texture: CompressedTexture2D = card.get_card_texture()
	var mesh: PlaneMesh = card.front.mesh.duplicate_deep()
	(mesh.material as StandardMaterial3D).albedo_texture = texture
	card.front.mesh = mesh


@rpc
func _sync_card(index: int, face: Card.FaceImage, symbol: Card.Symbol) -> void:
	var new_card: Card = cards.get(index)
	if not new_card: new_card = CARD.instantiate()
	new_card.face = face
	new_card.symbol = symbol
	new_card.is_placeholder = false
	set_card(index, new_card)
