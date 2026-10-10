extends Node
class_name InGameStore

## Fair & Balanced In-Game Store System (Gameplay & Cosmetics)

enum StoreCategory { ESSENTIAL_MATERIALS, UPGRADE_PARTS, OUTFIT_SKINS, WEAPON_SKINS, COMPANION_SKINS, CAMP_CUSTOMS }
enum CurrencyType { SCRAP_MARKS, PREMIUM_MARKS } # Soft currency (Earned) vs Premium currency (Earned/Purchased)

class StoreItem:
	var id: StringName
	var name: String
	var description: String
	var category: StoreCategory
	var currency: CurrencyType
	var price: int
	var icon_path: String
	var is_cosmetic: bool
	var is_unlocked: bool = false

	func _init(p_id: StringName, p_name: String, p_desc: String, p_cat: StoreCategory, p_curr: CurrencyType, p_price: int, p_cosmetic: bool = false) -> void:
		id = p_id
		name = p_name
		description = p_desc
		category = p_cat
		currency = p_curr
		price = p_price
		is_cosmetic = p_cosmetic

var catalog: Array[StoreItem] = []
var unlocked_cosmetics: Dictionary = {} # StringName -> bool

# Player Balances
var scrap_marks: int = 150 # Earnable in-game currency
var premium_marks: int = 20 # Can be earned through milestones or optional purchase

signal purchase_succeeded(item: StoreItem)
signal purchase_failed(reason: String)
signal balance_changed(scrap: int, premium: int)

func _ready() -> void:
	_setup_store_catalog()

func _setup_store_catalog() -> void:
	# 1. Essential Materials & Maintenance (Earned In-Game via Scrap Marks)
	catalog.append(StoreItem.new(&"mat.weapon_repair_kit", "Weapon Repair Tool", "Restores 50% durability to equipped firearms.", StoreCategory.UPGRADE_PARTS, CurrencyType.SCRAP_MARKS, 40))
	catalog.append(StoreItem.new(&"mat.camp_fortify_kit", "Reinforced Barricade Kit", "Upgrades campsite walls against wave attacks.", StoreCategory.UPGRADE_PARTS, CurrencyType.SCRAP_MARKS, 60))
	catalog.append(StoreItem.new(&"mat.gunpowder_crate", "Refined Gunpowder Crate", "Crafting material for 50x rounds of ammo.", StoreCategory.ESSENTIAL_MATERIALS, CurrencyType.SCRAP_MARKS, 25))
	catalog.append(StoreItem.new(&"mat.sanity_elixir_pack", "Mind-Shield Elixir Pack (x3)", "Restores full Sanity during dark storms.", StoreCategory.ESSENTIAL_MATERIALS, CurrencyType.SCRAP_MARKS, 35))

	# 2. Character Outfits & Cosmetics (Fair Hybrid: Earnable or Optional Premium)
	catalog.append(StoreItem.new(&"skin.outfit.duster_black", "Midnight Duster Coat", "Classic dark leather duster coat for the Gunslinger.", StoreCategory.OUTFIT_SKINS, CurrencyType.SCRAP_MARKS, 200, true))
	catalog.append(StoreItem.new(&"skin.outfit.gilead_knight", "Gilead High Knight Uniform", "Ornamental armor worn by ancient defenders of Gilead.", StoreCategory.OUTFIT_SKINS, CurrencyType.PREMIUM_MARKS, 50, true))

	# 3. Weapon Visual Skins (Cosmetic Only)
	catalog.append(StoreItem.new(&"skin.weapon.etched_steel", "Etched Steel Revolver Finish", "Intricate floral engravings on steel frame.", StoreCategory.WEAPON_SKINS, CurrencyType.SCRAP_MARKS, 150, true))
	catalog.append(StoreItem.new(&"skin.weapon.beam_runes", "Beam Rune Glowing Skin", "Mystical glowing blue runes carved into the barrel.", StoreCategory.WEAPON_SKINS, CurrencyType.PREMIUM_MARKS, 40, true))

	# 4. Companion Visual Skins (Cosmetic Only)
	catalog.append(StoreItem.new(&"skin.companion.armored_oy", "Armored Oy Skin", "Custom leather and metal vest for your Oy companion.", StoreCategory.COMPANION_SKINS, CurrencyType.SCRAP_MARKS, 180, true))
	catalog.append(StoreItem.new(&"skin.companion.golden_automaton", "Golden Automaton Companion", "Polished brass finish for cybernetic allies.", StoreCategory.COMPANION_SKINS, CurrencyType.PREMIUM_MARKS, 45, true))

	# 5. Campsite Visual Customs
	catalog.append(StoreItem.new(&"skin.camp.blue_fire", "Beam Flame Campfire FX", "Changes campfire flame to mystical blue light.", StoreCategory.CAMP_CUSTOMS, CurrencyType.SCRAP_MARKS, 120, true))

func purchase_item(item_id: StringName, player_data: PlayerData) -> bool:
	var item := _find_item(item_id)
	if item == null:
		purchase_failed.emit("Item not found in catalog.")
		return false

	if item.is_cosmetic and unlocked_cosmetics.get(item.id, false):
		purchase_failed.emit("Item already unlocked!")
		return false

	# Check currency
	if item.currency == CurrencyType.SCRAP_MARKS:
		if scrap_marks < item.price:
			purchase_failed.emit("Not enough Scrap Marks! Complete expeditions to earn more.")
			return false
		scrap_marks -= item.price
	else:
		if premium_marks < item.price:
			purchase_failed.emit("Not enough Premium Marks!")
			return false
		premium_marks -= item.price

	# Apply purchase
	if item.is_cosmetic:
		unlocked_cosmetics[item.id] = true
		item.is_unlocked = true
		GameLog.info("Unlocked Cosmetic: %s" % item.name)
	else:
		_apply_gameplay_item(item.id, player_data)

	balance_changed.emit(scrap_marks, premium_marks)
	purchase_succeeded.emit(item)
	return true

func add_rewards(scrap_amount: int, premium_amount: int = 0) -> void:
	scrap_marks += scrap_amount
	premium_marks += premium_amount
	balance_changed.emit(scrap_marks, premium_marks)
	GameLog.info("Earned Rewards: +%d Scrap Marks, +%d Premium Marks" % [scrap_amount, premium_amount])

func _apply_gameplay_item(item_id: StringName, player_data: PlayerData) -> void:
	if player_data == null:
		return
	match item_id:
		&"mat.weapon_repair_kit":
			GameLog.info("Used Weapon Repair Kit: Durability restored!")
		&"mat.camp_fortify_kit":
			GameLog.info("Used Barricade Kit: Campsite fortified!")
		&"mat.gunpowder_crate":
			player_data.reserve_ammo += 50
		&"mat.sanity_elixir_pack":
			player_data.restore_sanity(100.0)

func _find_item(item_id: StringName) -> StoreItem:
	for item in catalog:
		if item.id == item_id:
			return item
	return null
