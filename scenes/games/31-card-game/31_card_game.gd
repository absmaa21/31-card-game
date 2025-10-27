extends Node3D
class_name Game_31CardGame


const CARD: PackedScene = preload("uid://b0q72fruoa26k")
const CARD_HAND: PackedScene = preload("uid://cage2n7fxbf6i")
const PLAYER: PackedScene = preload("uid://dehn5gcvf2ex3")
const MAX_PLAYERS: int = 16

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
## Player Id who started the round and gets to choose is 3 start cards.
@export var cur_dealer: int:
	set(value):
		cur_dealer = value
		dealer_buttons.refresh()
@export var table_cards: CardHand

## Defines if the dealer kept the cards.[br]
## If null the dealer did not choose yet.
var dealer_kept_cards: bool
var cards_in_deck: Array[Card] = []

@onready var spawn_points: Node3D = $SpawnPoints
@onready var players: Node3D = $Players
@onready var state_machine: StateMachine = $StateMachine
@onready var dealer_buttons: DealerButtons = $DealerButtons


func _ready() -> void:
	initialize_game()


func initialize_game() -> void:
	if not multiplayer.is_server(): return
	print("----- GAME '31 Card Game' -----")
	create_players()
	state_machine.switch_state("prepare")


func create_players() -> void:
	for member: LobbyMember in Glob.lobby_manager.lobby_members:
		var spawn_point: Node3D = get_next_spawn_point()
		if not spawn_point:
			push_warning("Not enough spawn points to spawn all players!")
			return
		
		var player: Player31CardGame = PLAYER.instantiate()
		player.name = str(member.id)
		player.game = self
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


func get_player_by_id(id: int) -> Player31CardGame:
	for child: Player31CardGame in players.get_children():
		if child.corresponding_id == id:
			return child
	return null

func get_random_player() -> int:
	return (players.get_children().pick_random() as Player31CardGame).corresponding_id

func get_index_of_player_id(id: int) -> int:
	for i: int in range(players.get_child_count()):
		if id == players.get_child(i).corresponding_id:
			return i
	return -1

func get_player_id_by_index(index: int) -> int:
	return players.get_child(index % players.get_child_count()).corresponding_id


func deal_cards_to_hand(hand: CardHand) -> void:
	for i: int in range(3):
		hand.cards.set(i, cards_in_deck.pop_at(randi_range(0, cards_in_deck.size()-1)))
		hand._refresh_card(i)
	sync_all_cards(hand)
	print("CardHand for %s: %s" % [str(hand.parent.corresponding_id) if hand.parent else "Table", hand.to_string()])


func get_next_spawn_point() -> Node3D:
	var next_index: int = players.get_child_count()
	if spawn_points.get_child_count() < next_index: return null
	return spawn_points.get_child(next_index)


func sync_all_cards(hand: CardHand) -> void:
	for i: int in range(3):
		var card: Card = hand.cards.get(i)
		# This will prevent syncing cards of other players to other clients (prevent cheating)
		if hand.parent:
			if hand.parent.corresponding_id != multiplayer.get_unique_id():
				hand._sync_card.rpc_id(hand.parent.corresponding_id, i, card.face, card.symbol)
		else:
			hand._sync_card.rpc(i, card.face, card.symbol)


func next_player() -> void:
	var new_player_turn: int = get_player_id_by_index(get_index_of_player_id(current_player_turn if current_player_turn else cur_dealer) + 1)
	if new_player_turn == round_locked_by:
		state_machine.switch_state("after")
	current_player_turn = new_player_turn


@rpc("any_peer", "call_local")
func set_dealer_kept_cards(kept: bool) -> void:
	dealer_kept_cards = kept

	if kept:
		deal_cards_to_hand(table_cards)
	else:
		var dealer: Player31CardGame = get_player_by_id(cur_dealer)
		for i: int in range(3):
			table_cards.cards.set(i, dealer.card_hand.remove_card(i))
			table_cards._refresh_card(i)
		sync_all_cards(table_cards)

	var dealer_index: int = get_index_of_player_id(cur_dealer)
	var start_index: int = dealer_index + 1 if kept else dealer_index
	for i: int in range(start_index, players.get_child_count()) + range(0, dealer_index):
		var player: Player31CardGame = get_player_by_id(get_player_id_by_index(i))
		deal_cards_to_hand(player.card_hand)

	state_machine.switch_state("core")
