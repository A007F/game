extends CanvasLayer
class_name QuickSelectWheel

signal item_selected(item_id: StringName)

@onready var wheel_panel: Panel = $WheelPanel if has_node("WheelPanel") else null

var is_open: bool = false
var player_data: PlayerData

func _ready() -> void:
	layer = 20
	_build_wheel_ui()
	visible = false

func _build_wheel_ui() -> void:
	if get_node_or_null("WheelPanel") != null:
		return

	wheel_panel = Panel.new()
	wheel_panel.name = "WheelPanel"
	wheel_panel.set_anchors_preset(Control.PRESET_CENTER)
	wheel_panel.custom_minimum_size = Vector2(300, 300)
	wheel_panel.position = -Vector2(150, 150)
	add_child(wheel_panel)

	var title := Label.new()
	title.text = "QUICK SELECT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(300, 30)
	wheel_panel.add_child(title)

	var btn_revolver := Button.new()
	btn_revolver.text = "1. Revolver"
	btn_revolver.position = Vector2(20, 60)
	btn_revolver.size = Vector2(120, 40)
	btn_revolver.pressed.connect(func(): _select_item(&"weapon.revolver"))
	wheel_panel.add_child(btn_revolver)

	var btn_rifle := Button.new()
	btn_rifle.text = "2. Lever-Rifle"
	btn_rifle.position = Vector2(160, 60)
	btn_rifle.size = Vector2(120, 40)
	btn_rifle.pressed.connect(func(): _select_item(&"weapon.rifle"))
	wheel_panel.add_child(btn_rifle)

	var btn_bandage := Button.new()
	btn_bandage.text = "3. Bandage (+HP)"
	btn_bandage.position = Vector2(20, 140)
	btn_bandage.size = Vector2(120, 40)
	btn_bandage.pressed.connect(func(): _select_item(&"use.bandage"))
	wheel_panel.add_child(btn_bandage)

	var btn_tonic := Button.new()
	btn_tonic.text = "4. Sanity Tonic"
	btn_tonic.position = Vector2(160, 140)
	btn_tonic.size = Vector2(120, 40)
	btn_tonic.pressed.connect(func(): _select_item(&"use.sanity_tonic"))
	wheel_panel.add_child(btn_tonic)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_Q:
		if event.is_pressed() and not event.is_echo():
			toggle_wheel()

func toggle_wheel() -> void:
	is_open = not is_open
	visible = is_open
	if is_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _select_item(id: StringName) -> void:
	toggle_wheel()
	item_selected.emit(id)
	GameLog.info("Quick Select used: %s" % id)

	if player_data == null and GameManager.session:
		player_data = GameManager.session.entities.get_player(&"player.main")

	if player_data:
		match id:
			&"use.bandage":
				player_data.heal(35.0)
			&"use.sanity_tonic":
				player_data.restore_sanity(50.0)
