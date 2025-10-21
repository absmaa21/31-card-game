extends CanvasLayer
class_name LobbyMenu


@onready var member_list: PanelContainer = $MarginContainer/VBoxContainer/MemberList
@onready var leave_lobby_button: Button = %LeaveLobbyButton
@onready var lobby_name_field: TextEdit = %LobbyName


func _ready() -> void:
	Glob.lobby_manager.lobby_members_updated.connect(_on_lobby_members_updated)
	leave_lobby_button.pressed.connect(Glob.lobby_manager.leave_lobby)
	Glob.lobby_manager.lobby_data_updated.connect(_on_lobby_data_updated)

	for key: String in Glob.lobby_manager.lobby_data.keys():
		_on_lobby_data_updated(key, Glob.lobby_manager.lobby_data.get(key))


func _on_lobby_members_updated(members: Array[LobbyMember]) -> void:
	for child: Node in member_list.get_children():
		child.queue_free()

	for member: LobbyMember in members:
		var label: RichTextLabel = RichTextLabel.new()
		label.text = "%s (%d)" % [member.username, member.id]


func _on_lobby_data_updated(key: String, value: String) -> void:
	if key == "lobby_name":
		lobby_name_field.text = value
