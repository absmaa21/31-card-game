extends Node3D

@export var player: Player31CardGame

@onready var switch_btn: HoldButton3D = $Switch
@onready var skip_btn: HoldButton3D = $Skip
@onready var lock_btn: HoldButton3D = $Lock


func _ready() -> void:
	switch_btn.button.text = "Switch"
	switch_btn.timeout_method = _switch_btn_timeout
	skip_btn.button.text = "Skip"
	skip_btn.timeout_method = _skip_btn_timeout
	lock_btn.button.text = "Lock"
	lock_btn.timeout_method = _lock_btn_timeout


func _switch_btn_timeout() -> void:
	var player_index: int = player.game.get_index_of_selected_card(player.card_hand)
	var table_index: int = player.game.get_index_of_selected_card(player.game.table_cards)
	if multiplayer.is_server():
		player.game.on_player_round_finish(player.corresponding_id, player_index, table_index)
	else:
		player.game.on_player_round_finish.rpc_id(1, player.corresponding_id, player_index, table_index)


func _skip_btn_timeout() -> void:
	if multiplayer.is_server():
		player.game.on_player_round_finish(player.corresponding_id, -1, -1)
	else:
		player.game.on_player_round_finish.rpc_id(1, player.corresponding_id, -1, -1)


func _lock_btn_timeout() -> void:
	player.game.round_locked_by = player.corresponding_id
	if multiplayer.is_server():
		player.game.on_player_round_finish(player.corresponding_id, -1, -1, true)
	else:
		player.game.on_player_round_finish.rpc_id(1, player.corresponding_id, -1, -1, true)
