extends State
## 

@export var game: Game_31CardGame


func transition_to() -> void:
	if not multiplayer.is_server(): return

	game.dealer_buttons.refresh()
	game.next_player()
