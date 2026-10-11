extends Node
class_name StoreRotationManager

signal rotation_updated(discounted_items_count: int)

var active_discounts: Dictionary = {} # StringName -> float (discount factor e.g. 0.8 for 20% off)

func apply_weekly_rotation(store: InGameStore) -> void:
	if store == null:
		return

	active_discounts.clear()

	# Apply 25% discount to Gilead Knight outfit and Etched Steel Revolver skin
	active_discounts[&"skin.outfit.gilead_knight"] = 0.75
	active_discounts[&"skin.weapon.etched_steel"] = 0.75

	for item in store.catalog:
		if active_discounts.has(item.id):
			var factor: float = active_discounts[item.id]
			item.price = int(item.price * factor)

	rotation_updated.emit(active_discounts.size())
	GameLog.info("WEEKLY STORE ROTATION APPLIED! %d items featured with 25%% discount!" % active_discounts.size())
