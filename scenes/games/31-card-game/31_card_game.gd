extends Node3D

## Number of rounds passed. 0 means preparing.
var round_num: int = 0
## After a player locks, every other player can make one last turn.
var round_locked_by: LobbyMember = null
var available_cards: Array[Card] = []
var table_cards: CardHand = CardHand.new()
var player_hands: Dictionary[int, CardHand] = {}


func _ready() -> void:
	initialize_game()


func initialize_game() -> void:
	if not multiplayer.is_server(): return
	print("----- GAME '31 Card Game' -----")
	create_players()
	create_card_deck()
	deal_cards_to_players()


func create_players() -> void:
	for member: LobbyMember in [Glob.player_data] + Glob.lobby_manager.lobby_members:
		player_hands.set(member.id, CardHand.new())
	print("All players created.")


func create_card_deck(min_face_image: Card.FaceImage = Card.FaceImage.SIX) -> void:
	for symbol: Card.Symbol in Card.Symbol.values():
		for face: Card.FaceImage in Card.FaceImage.values():
			if face < min_face_image: continue
			available_cards.append(Card.new(symbol, face))
	print("Card Deck created with minimum face %s. Amount %d" % [Card.FaceImage.keys()[min_face_image], available_cards.size()])


func deal_cards_to_players() -> void:
	for player: int in player_hands.keys():
		var hand: CardHand = player_hands.get(player)
		hand.cards.set(0, available_cards.pop_at(randi_range(0, available_cards.size())))
		hand.cards.set(1, available_cards.pop_at(randi_range(0, available_cards.size())))
		hand.cards.set(2, available_cards.pop_at(randi_range(0, available_cards.size())))
		player_hands.set(player, hand)
		print("CardHand for %d: %s" % [player, hand.to_string()])
