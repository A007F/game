extends CanvasLayer
class_name CombatHUD

@onready var health_bar: ProgressBar = $Control/VBoxContainer/HealthBar if has_node("Control/VBoxContainer/HealthBar") else null
@onready var sanity_bar: ProgressBar = $Control/VBoxContainer/SanityBar if has_node("Control/VBoxContainer/SanityBar") else null
@onready var ammo_label: Label = $Control/VBoxContainer/AmmoLabel if has_node("Control/VBoxContainer/AmmoLabel") else null
@onready var weapon_label: Label = $Control/VBoxContainer/WeaponLabel if has_node("Control/VBoxContainer/WeaponLabel") else null

var player_data: PlayerData

func _ready() -> void:
	layer = 10
	_build_ui_if_missing()

func _build_ui_if_missing() -> void:
	if get_node_or_null("Control") != null:
		return

	var control := Control.new()
	control.name = "Control"
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(control)

	# Bottom-left stats panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	panel.position = Vector2(20, -160)
	panel.custom_minimum_size = Vector2(240, 140)
	control.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBoxContainer"
	panel.add_child(vbox)

	var h_label := Label.new()
	h_label.text = "HEALTH"
	vbox.add_child(h_label)

	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.max_value = 100.0
	health_bar.value = 100.0
	health_bar.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(health_bar)

	var s_label := Label.new()
	s_label.text = "SANITY"
	vbox.add_child(s_label)

	sanity_bar = ProgressBar.new()
	sanity_bar.name = "SanityBar"
	sanity_bar.max_value = 100.0
	sanity_bar.value = 100.0
	sanity_bar.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(sanity_bar)

	weapon_label = Label.new()
	weapon_label.name = "WeaponLabel"
	weapon_label.text = "Weapon: Revolver"
	vbox.add_child(weapon_label)

	ammo_label = Label.new()
	ammo_label.name = "AmmoLabel"
	ammo_label.text = "AMMO: 6 / 36"
	vbox.add_child(ammo_label)

	# Crosshair in center
	var crosshair := TextureRect.new()
	crosshair.name = "Crosshair"
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.custom_minimum_size = Vector2(8, 8)
	control.add_child(crosshair)

func _process(_delta: float) -> void:
	if player_data == null:
		if GameManager.session:
			player_data = GameManager.session.entities.get_player(&"player.main")
		return

	if health_bar:
		health_bar.max_value = player_data.max_health
		health_bar.value = player_data.current_health

	if sanity_bar:
		sanity_bar.max_value = player_data.max_sanity
		sanity_bar.value = player_data.sanity

	if ammo_label:
		ammo_label.text = "AMMO: %d / %d" % [player_data.current_ammo, player_data.reserve_ammo]
