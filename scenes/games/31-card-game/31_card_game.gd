extends Node3D


const PLAYER: PackedScene = preload("uid://dehn5gcvf2ex3")

## Number of rounds passed. 0 means preparing.
var round_num: int = 0
## After a player locks, every other player can make one last turn.
var round_locked_by: LobbyMember = null
var cards_in_deck: Array[Card] = []
var table_cards: CardHand = CardHand.new()
var player_hands: Dictionary[int, CardHand] = {}

@onready var spawn_points: Node3D = $SpawnPoints
@onready var players: Node3D = $Players


func _ready() -> void:
	initialize_game()


func initialize_game() -> void:
	if not multiplayer.is_server(): return
	print("----- GAME '31 Card Game' -----")
	create_players()
	create_card_deck()
	deal_cards_to_players()


func create_players() -> void:
	for member: LobbyMember in Glob.lobby_manager.lobby_members:
		var spawn_point: Node3D = get_next_spawn_point()
		if not spawn_point:
			push_warning("Not enough spawn points to spawn all players!")
			return
		
		player_hands.set(member.id, CardHand.new())
		var player: Player31CardGame = PLAYER.instantiate()
		player.name = str(member.id)
		players.add_child(player, true)
		player.global_position = spawn_point.global_position
		player.rotation_degrees.y = spawn_point.rotation_degrees.y - 90

	print("All players created.")


func create_card_deck(min_face_image: Card.FaceImage = Card.FaceImage.SIX) -> void:
	for symbol: Card.Symbol in Card.Symbol.values():
		for face: Card.FaceImage in Card.FaceImage.values():
			if face < min_face_image: continue
			cards_in_deck.append(Card.new(symbol, face))
	print("Card Deck created with minimum face %s. Amount %d" % [Card.FaceImage.keys()[min_face_image], cards_in_deck.size()])


func deal_cards_to_players() -> void:
	for player: int in player_hands.keys():
		var hand: CardHand = player_hands.get(player)
		for i: int in range(3):
			hand.cards.set(i, cards_in_deck.pop_at(randi_range(0, cards_in_deck.size()-1)))
		player_hands.set(player, hand)
		print("CardHand for %d: %s" % [player, hand.to_string()])


func get_next_spawn_point() -> Node3D:
	var next_index: int = players.get_children().size()
	if spawn_points.get_child_count() < next_index: return null
	return spawn_points.get_child(next_index)
