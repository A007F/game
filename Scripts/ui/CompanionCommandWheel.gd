extends CanvasLayer
class_name CompanionCommandWheel

signal command_issued(command: StringName)

@onready var panel: Panel = $CommandPanel if has_node("CommandPanel") else null

var is_open: bool = false

func _ready() -> void:
	layer = 21
	_build_wheel_ui()
	visible = false

func _build_wheel_ui() -> void:
	if get_node_or_null("CommandPanel") != null:
		return

	panel = Panel.new()
	panel.name = "CommandPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 260)
	panel.position = -Vector2(150, 130)
	add_child(panel)

	var title := Label.new()
	title.text = "COMPANION COMMANDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(300, 30)
	panel.add_child(title)

	var btn_follow := Button.new()
	btn_follow.text = "Follow Me"
	btn_follow.position = Vector2(20, 60)
	btn_follow.size = Vector2(120, 40)
	btn_follow.pressed.connect(func(): _issue_command(&"cmd.follow"))
	panel.add_child(btn_follow)

	var btn_defend := Button.new()
	btn_defend.text = "Defend Area"
	btn_defend.position = Vector2(160, 60)
	btn_defend.size = Vector2(120, 40)
	btn_defend.pressed.connect(func(): _issue_command(&"cmd.defend"))
	panel.add_child(btn_defend)

	var btn_attack := Button.new()
	btn_attack.text = "Attack Nearest"
	btn_attack.position = Vector2(20, 140)
	btn_attack.size = Vector2(120, 40)
	btn_attack.pressed.connect(func(): _issue_command(&"cmd.attack"))
	panel.add_child(btn_attack)

	var btn_gather := Button.new()
	btn_gather.text = "Gather Loot"
	btn_gather.position = Vector2(160, 140)
	btn_gather.size = Vector2(120, 40)
	btn_gather.pressed.connect(func(): _issue_command(&"cmd.gather"))
	panel.add_child(btn_gather)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_TAB:
		if event.is_pressed() and not event.is_echo():
			toggle_wheel()

func toggle_wheel() -> void:
	is_open = not is_open
	visible = is_open
	if is_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _issue_command(cmd: StringName) -> void:
	toggle_wheel()
	command_issued.emit(cmd)
	GameLog.info("Companion Command: %s" % cmd)

	# Dispatch to all companions in group
	var companions := get_tree().get_nodes_in_group("companions")
	for companion in companions:
		if companion.has_method("receive_command"):
			companion.receive_command(cmd)
