extends Node

func _ready() -> void:
	print("--- Running Comprehensive Game Enhancements Verification Test ---")

	# 1. Test SkillTree leveling and Iron Will perk
	var skill_tree := SkillTree.new()
	assert(skill_tree.level == 1, "Initial level should be 1")
	skill_tree.add_xp(100)
	assert(skill_tree.level == 2, "Level should be 2 after 100 XP")
	assert(skill_tree.skill_points == 1, "Should have 1 skill point")

	var unlock_ok := skill_tree.unlock_perk(&"iron_will")
	assert(unlock_ok, "Iron Will perk should unlock")
	assert(skill_tree.has_perk(&"iron_will"), "Iron Will perk verified")

	var player_data := PlayerData.new()
	player_data.skill_tree = skill_tree
	player_data.drain_sanity(10.0)
	assert(player_data.sanity == 93.0, "Sanity should be 93 after 30% Iron Will reduction (10 * 0.7 = 7)")

	# 2. Test WaystationDoor3D
	var door := WaystationDoor3D.new()
	var dummy_player := Node3D.new()
	var door_ok := door.try_enter_door(dummy_player)
	assert(door_ok, "Door entry should succeed")
	assert(dummy_player.global_position == door.target_coordinates, "Player teleported to target coordinates")

	# 3. Test BeamStormManager
	var storm_mgr := BeamStormManager.new()
	storm_mgr.start_storm()
	assert(storm_mgr.is_storm_active, "Storm should be active")
	storm_mgr.end_storm()
	assert(not storm_mgr.is_storm_active, "Storm should be ended")

	# 4. Test VisualShopUI instantiation
	var shop_ui := VisualShopUI.new()
	assert(shop_ui.store_system != null, "Shop UI store system initialized")

	print("--- All Comprehensive Game Enhancements Verification Tests Passed! ---")
	queue_free()
