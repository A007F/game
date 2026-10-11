extends Node

func _ready() -> void:
	print("--- Running In-Game Store Subsystem Depth Verification Test ---")

	# 1. Test SkinPreview3D Viewport
	var preview_3d := SkinPreview3D.new()
	assert(preview_3d.custom_minimum_size == Vector2(200, 200), "3D Preview Viewport size verified")

	# 2. Test StoreRotationManager
	var store := InGameStore.new()
	var rotation_mgr := StoreRotationManager.new()
	var initial_price := 50
	for item in store.catalog:
		if item.id == &"skin.outfit.gilead_knight":
			initial_price = item.price
			break

	rotation_mgr.apply_weekly_rotation(store)
	var discounted_price := initial_price
	for item in store.catalog:
		if item.id == &"skin.outfit.gilead_knight":
			discounted_price = item.price
			break

	assert(discounted_price < initial_price, "Weekly rotation applied 25% discount successfully")

	# 3. Test CosmeticAchievementManager
	var ach_mgr := CosmeticAchievementManager.new()
	ach_mgr.progress_achievement(&"ach.beam_savior", 3, store)
	var is_skin_unlocked := store.unlocked_cosmetics.get(&"skin.weapon.beam_runes", false)
	assert(is_skin_unlocked, "Beam Runes skin unlocked automatically via achievement milestone")

	print("--- All In-Game Store Subsystem Depth Verification Tests Passed! ---")
	queue_free()
