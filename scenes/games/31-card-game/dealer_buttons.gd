extends Node3D
class_name DealerButtons

@export var game: Game_31CardGame

@onready var keep_button: Button3D = $KeepButton
@onready var give_button: Button3D = $GiveButton


func _ready() -> void:
	keep_button.button.pressed.connect(func() -> void:
		game.set_dealer_kept_cards.rpc_id(1, true)
		refresh()
	)
	give_button.button.pressed.connect(func() -> void:
		game.set_dealer_kept_cards.rpc_id(1, false)
		refresh()
	)


func refresh() -> void:
	visible = multiplayer.get_unique_id() == game.cur_dealer and game.state_machine.equals_cur_state("prepare")
	var dealer: Player31CardGame = game.get_player_by_id(game.cur_dealer)
	look_at(Vector3(
		dealer.global_position.x,
		self.global_position.y,
		dealer.global_position.z
	))
	self.rotation_degrees.y += 180
