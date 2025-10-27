extends State
## Dealer gets to choose if he keeps the 3 first drawn cards.[br]
## If not he gets the next 3.[br]
## After all that all other players will get their cards dealed.


@export var game: Game_31CardGame


func transition_to() -> void:
	if not multiplayer.is_server(): return

	# TODO Calculate min_face_image corresponding to player amount
	game.create_card_deck()

	# If it is not the first round, there will be a dealer already. So just go to the next one.
	if game.cur_dealer != null:
		var index: int = game.get_index_of_player_id(game.cur_dealer)
		game.cur_dealer = game.get_player_id_by_index(index + 1)
	else:
		game.cur_dealer = game.get_random_player()

	var dealer: Player31CardGame = game.get_player_by_id(game.cur_dealer)
	game.deal_cards_to_hand(dealer.card_hand)
