extends State

@export var game: Game_31CardGame


func transition_to() -> void:
	if not multiplayer.is_server(): return

	var player_card_values: Dictionary[int, float] = {}
	var best_player: int
	for player: Player31CardGame in game.players.get_children():
		var card_value: float = game.get_combined_card_values(player.card_hand)
		print("Combined Card value of player %d: %d" % [player.corresponding_id, card_value])
		player_card_values.set(player.corresponding_id, card_value)
		if not best_player or card_value > player_card_values.get(best_player):
			best_player = player.corresponding_id

	print("The Best player is %d with a score of %d" % [best_player, player_card_values.get(best_player)])
