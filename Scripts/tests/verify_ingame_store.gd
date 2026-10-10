extends Node

func _ready() -> void:
	print("--- Running In-Game Store Verification Test ---")
	var store := InGameStore.new()
	var player_data := PlayerData.new()

	# Verify initial balance
	assert(store.scrap_marks == 150, "Initial scrap marks should be 150")
	assert(store.premium_marks == 20, "Initial premium marks should be 20")

	# Test purchasing essential gameplay materials with in-game currency
	var success := store.purchase_item(&"mat.gunpowder_crate", player_data)
	assert(success, "Should buy gunpowder crate successfully")
	assert(player_data.reserve_ammo == 86, "Reserve ammo should increase by 50 (36 + 50 = 86)")
	assert(store.scrap_marks == 125, "Scrap marks should be 125 (150 - 25 = 125)")

	# Test earning rewards from gameplay
	store.add_rewards(100, 10)
	assert(store.scrap_marks == 225, "Scrap marks should be 225")
	assert(store.premium_marks == 30, "Premium marks should be 30")

	# Test purchasing cosmetic item
	var cosmetic_success := store.purchase_item(&"skin.outfit.duster_black", player_data)
	assert(cosmetic_success, "Should purchase cosmetic outfit")
	assert(store.unlocked_cosmetics.get(&"skin.outfit.duster_black") == true, "Duster skin unlocked")

	print("--- In-Game Store Verification Test Passed! ---")
	queue_free()
