extends Node3D
class_name Game_31CardGame


const CARD: PackedScene = preload("uid://b0q72fruoa26k")
const CARD_HAND = preload("uid://cage2n7fxbf6i")
const PLAYER: PackedScene = preload("uid://dehn5gcvf2ex3")

## Id of player which can make its play right now.
@export var current_player_turn: int:
	set(value):
		current_player_turn = value
		MessageBus.current_player_turn_changed.emit(value)
## Number of rounds passed. 0 means preparing.
@export var round_num: int = 0
## The player id which locked the current round.[br]
## After a player locks, every other player can make one last turn.
@export var round_locked_by: int
## Player Id who started the round.
@export var first_player: int

var cards_in_deck: Array[Card] = []
var table_cards: CardHand

@onready var spawn_points: Node3D = $SpawnPoints
@onready var players: Node3D = $Players
@onready var card_hands: Node3D = $CardHands


func _ready() -> void:
	initialize_game()


func initialize_game() -> void:
	if not multiplayer.is_server(): return
	print("----- GAME '31 Card Game' -----")
	create_players()
	next_round()


func create_players() -> void:
	for member: LobbyMember in Glob.lobby_manager.lobby_members:
		var spawn_point: Node3D = get_next_spawn_point()
		if not spawn_point:
			push_warning("Not enough spawn points to spawn all players!")
			return
		
		var player: Player31CardGame = PLAYER.instantiate()
		player.name = str(member.id)
		players.add_child(player, true)
		player.spawn_point_path = spawn_point.get_path()
		player.input_sync.set_multiplayer_authority(member.id)
		player.global_position = spawn_point.global_position
		player.rotation_degrees.y = spawn_point.rotation_degrees.y - 90
		player.base_rot_y = player.camera.rotation.y
		player.card_hand.global_position = player.spawn_point.get_child(0).global_position
		player.card_hand.global_rotation = player.spawn_point.get_child(0).global_rotation

	print("All players created.")


func create_card_deck(min_face_image: Card.FaceImage = Card.FaceImage.SIX) -> void:
	for symbol: Card.Symbol in Card.Symbol.values():
		for face: Card.FaceImage in Card.FaceImage.values():
			if face < min_face_image: continue
			var card: Card = CARD.instantiate()
			card.symbol = symbol
			card.face = face
			cards_in_deck.append(card)
	print("Card Deck created with minimum face %s. Amount %d" % [Card.FaceImage.keys()[min_face_image], cards_in_deck.size()])


func deal_cards_to_players() -> void:
	for player: Player31CardGame in players.get_children():
		for i: int in range(3): 
			player.card_hand.cards.set(i, cards_in_deck.pop_at(randi_range(0, cards_in_deck.size()-1)))
			player.card_hand._refresh_card(i)
		
		sync_all_cards(player)
		print("CardHand for %d: %s" % [player.corresponding_id, player.card_hand.to_string()])


func get_next_spawn_point() -> Node3D:
	var next_index: int = players.get_child_count()
	if spawn_points.get_child_count() < next_index: return null
	return spawn_points.get_child(next_index)


func sync_all_cards(player: Player31CardGame) -> void:
	if player.corresponding_id == multiplayer.get_unique_id(): return
	for i: int in range(3):
		var card: Card = player.card_hand.cards.get(i)
		# This will prevent syncing cards of other players to other clients (prevent cheating)
		player.card_hand._sync_card.rpc_id(player.corresponding_id, i, card.face, card.symbol)


func next_round() -> void:
	round_num += 1
	create_card_deck()
	deal_cards_to_players()
	first_player = int(players.get_children().get(randi_range(0, players.get_child_count()-1)).name)
	current_player_turn = first_player
