extends Node
class_name ShopSystem

## Trading / Barter item catalog for Waystation Merchants
class TradeItem:
	var item_id: StringName
	var display_name: String
	var price_in_scrap: int
	var description: String

	func _init(id: StringName, name: String, price: int, desc: String) -> void:
		item_id = id
		display_name = name
		price_in_scrap = price
		description = desc

var shop_catalog: Array[TradeItem] = []

func _ready() -> void:
	_init_catalog()

func _init_catalog() -> void:
	shop_catalog.append(TradeItem.new(&"ammo.revolver_box", "Revolver Ammo Box (24 Rds)", 15, "Standard caliber rounds for Gunslinger revolvers."))
	shop_catalog.append(TradeItem.new(&"ammo.rifle_box", "Lever-Rifle Ammo Box (12 Rds)", 25, "Heavy caliber rifle rounds."))
	shop_catalog.append(TradeItem.new(&"item.sanity_tonic", "Mind-Shield Tonic", 30, "Restores 50 Sanity and cures hallucinations."))
	shop_catalog.append(TradeItem.new(&"item.bandage", "Waystation Bandage", 10, "Restores 35 Health and stops bleeding."))
	shop_catalog.append(TradeItem.new(&"item.scrap_metal", "Old Ones Tech Scrap", 20, "Used for crafting and upgrading weapons at camp."))
	shop_catalog.append(TradeItem.new(&"item.beam_lantern", "Beam Energy Lantern", 40, "Repels Slow Mutants and dark aura in nighttime hours."))

func buy_item(trade_item: TradeItem, player_data: PlayerData) -> bool:
	if player_data == null:
		return false

	# Assume player currency is stored in scrap/ammo
	if player_data.reserve_ammo < trade_item.price_in_scrap:
		GameLog.warn("Not enough scrap/currency to buy %s!" % trade_item.display_name)
		return false

	player_data.reserve_ammo -= trade_item.price_in_scrap
	GameLog.info("Purchased %s for %d currency!" % [trade_item.display_name, trade_item.price_in_scrap])

	# Apply item effect or add to inventory
	if trade_item.item_id == &"item.sanity_tonic":
		player_data.restore_sanity(50.0)
	elif trade_item.item_id == &"item.bandage":
		player_data.heal(35.0)
	elif trade_item.item_id == &"ammo.revolver_box":
		player_data.reserve_ammo += 24

	return true
