extends CanvasLayer
class_name LobbyMenu


@onready var member_list: PanelContainer = $MarginContainer/VBoxContainer/MemberList
@onready var leave_lobby_button: Button = %LeaveLobbyButton
@onready var lobby_name_field: TextEdit = %LobbyName


func _ready() -> void:
	Glob.lobby_manager.lobby_members_updated.connect(_on_lobby_members_updated)
	leave_lobby_button.pressed.connect(Glob.lobby_manager.leave_lobby)
	Steam.lobby_data_update.connect(_on_lobby_data_update)


func _on_lobby_members_updated(members: Array[LobbyMember]) -> void:
	for child: Node in member_list.get_children():
		child.queue_free()

	for member: LobbyMember in members:
		var label: RichTextLabel = RichTextLabel.new()
		label.text = "%s (%d)" % [member.username, member.id]


func _on_lobby_data_update(_success: int, lobby_id: int, _member_id: int) -> void:
	if lobby_id != Glob.lobby_manager.lobby_id:
		push_error("Lobby ids are not matching!")
		return
	lobby_name_field.text = Glob.lobby_manager.get_lobby_data("name")
