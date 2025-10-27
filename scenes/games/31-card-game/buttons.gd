extends Node3D

@onready var game: Game_31CardGame = $".."

func _ready() -> void:
	MessageBus.current_player_turn_changed.connect(_on_cur_player_turn_changed)


func _on_cur_player_turn_changed(id: int) -> void:
	for player: Player31CardGame in game.players.get_children():
		if player.corresponding_id == id:
			look_at(Vector3(
				player.global_position.x,
				self.global_position.y,
				player.global_position.z
			))
