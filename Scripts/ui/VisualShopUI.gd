extends CanvasLayer
class_name VisualShopUI

@onready var main_panel: Panel = $MainPanel if has_node("MainPanel") else null
@onready var balance_label: Label = $MainPanel/BalanceLabel if has_node("MainPanel/BalanceLabel") else null
@onready var item_container: VBoxContainer = $MainPanel/ScrollContainer/ItemContainer if has_node("MainPanel/ScrollContainer/ItemContainer") else null

var store_system: InGameStore
var is_open: bool = false

func _ready() -> void:
	layer = 15
	store_system = InGameStore.new()
	add_child(store_system)
	_build_shop_gui()
	store_system.balance_changed.connect(_update_balance_ui)
	visible = false

func _build_shop_gui() -> void:
	if get_node_or_null("MainPanel") != null:
		return

	main_panel = Panel.new()
	main_panel.name = "MainPanel"
	main_panel.set_anchors_preset(Control.PRESET_CENTER)
	main_panel.custom_minimum_size = Vector2(720, 420)
	main_panel.position = -Vector2(360, 210)
	add_child(main_panel)

	var title := Label.new()
	title.text = "WAYSTATION & COSMETICS STORE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(720, 30)
	main_panel.add_child(title)

	balance_label = Label.new()
	balance_label.name = "BalanceLabel"
	balance_label.position = Vector2(20, 40)
	balance_label.size = Vector2(460, 25)
	main_panel.add_child(balance_label)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 75)
	scroll.size = Vector2(460, 290)
	main_panel.add_child(scroll)

	# 3D Skin Preview viewport on the right side
	var preview_3d := SkinPreview3D.new()
	preview_3d.position = Vector2(490, 75)
	main_panel.add_child(preview_3d)

	item_container = VBoxContainer.new()
	item_container.name = "ItemContainer"
	item_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(item_container)

	var btn_close := Button.new()
	btn_close.text = "Close Store"
	btn_close.position = Vector2(290, 375)
	btn_close.size = Vector2(140, 30)
	btn_close.pressed.connect(toggle_shop)
	main_panel.add_child(btn_close)

	_refresh_items_ui()
	_update_balance_ui(store_system.scrap_marks, store_system.premium_marks)

func _update_balance_ui(scrap: int, premium: int) -> void:
	if balance_label:
		balance_label.text = "Scrap Marks: %d | Premium Marks: %d" % [scrap, premium]

func _refresh_items_ui() -> void:
	if item_container == null:
		return

	for child in item_container.get_children():
		child.queue_free()

	for item in store_system.catalog:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 35)

		var name_lbl := Label.new()
		name_lbl.text = item.name + (" (UNLOCKED)" if item.is_unlocked else "")
		name_lbl.custom_minimum_size = Vector2(220, 0)
		row.add_child(name_lbl)

		var curr_name := "Scrap" if item.currency == InGameStore.CurrencyType.SCRAP_MARKS else "Gold"
		var price_lbl := Label.new()
		price_lbl.text = "%d %s" % [item.price, curr_name]
		price_lbl.custom_minimum_size = Vector2(90, 0)
		row.add_child(price_lbl)

		var btn_buy := Button.new()
		btn_buy.text = "Unlocked" if item.is_unlocked else "Buy"
		btn_buy.disabled = item.is_unlocked
		btn_buy.custom_minimum_size = Vector2(80, 0)
		btn_buy.pressed.connect(func(): _buy_item(item.id))
		row.add_child(btn_buy)

		item_container.add_child(row)

func _buy_item(item_id: StringName) -> void:
	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if store_system.purchase_item(item_id, player_data):
		_refresh_items_ui()

func toggle_shop() -> void:
	is_open = not is_open
	visible = is_open
	if is_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_refresh_items_ui()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_B:
		if event.is_pressed() and not event.is_echo():
			toggle_shop()
