extends MarginContainer
class_name LobbyButton

@onready var button: Button = $Button
@onready var lobby_name: RichTextLabel = %LobbyName
@onready var lobby_mode: RichTextLabel = %LobbyMode
@onready var player_count: RichTextLabel = %PlayerCount

var lobby_id: int = 0


func _ready() -> void:
	button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	Glob.lobby_manager.join_lobby(lobby_id, "")
