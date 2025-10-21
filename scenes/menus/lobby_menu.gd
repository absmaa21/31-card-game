extends CanvasLayer
class_name LobbyMenu


@onready var member_list: PanelContainer = $MarginContainer/VBoxContainer/MemberList
@onready var leave_lobby_button: Button = %LeaveLobbyButton


func _ready() -> void:
	LobbyManager.lobby_members_updated.connect(_on_lobby_members_updated)
	leave_lobby_button.pressed.connect(LobbyManager.leave_lobby)


func _on_lobby_members_updated(members: Array[LobbyMember]) -> void:
	for child: Node in member_list.get_children():
		child.queue_free()

	for member: LobbyMember in members:
		var label: RichTextLabel = RichTextLabel.new()
		label.text = "%s (%d)" % [member.steam_name, member.steam_id]
