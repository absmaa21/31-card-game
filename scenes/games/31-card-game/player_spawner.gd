extends MultiplayerSpawner

@export var game: Game_31CardGame


func _ready() -> void:
	spawned.connect(_on_spawned)


func _on_spawned(node: Node) -> void:
	if node is Player31CardGame:
		node.input_sync.set_multiplayer_authority(node.corresponding_id)
		node.game = game
