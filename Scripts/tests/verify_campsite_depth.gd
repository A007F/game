extends Node

func _ready() -> void:
	print("--- Running Campsite & Expedition Subsystem Depth Verification Test ---")

	# 1. Test CampWorkbench crafting
	var workbench := CampWorkbench.new()
	var player_data := PlayerData.new()
	player_data.reserve_ammo = 30

	var craft_ok := workbench.craft_ammo(player_data, 15, 30)
	assert(craft_ok, "Craft ammo should succeed")
	assert(player_data.reserve_ammo == 60, "Reserve ammo increased to 60 (30 + 30)")

	var tonic_ok := workbench.brew_sanity_tonic(player_data)
	assert(tonic_ok, "Brew sanity tonic should succeed")

	# 2. Test Campsite3D barricade upgrades
	var camp := Campsite3D.new()
	assert(camp.barricade_level == 1, "Initial barricade level is 1")
	camp.upgrade_barricade()
	assert(camp.barricade_level == 2, "Barricade upgraded to level 2")
	assert(camp.comfort_radius == 11.0, "Comfort radius expanded to 11m (8 + 3)")

	# 3. Test ExpeditionQuestGenerator
	var quest_gen := ExpeditionQuestGenerator.new()
	quest_gen.generate_daily_quests()
	assert(quest_gen.active_quests.size() == 3, "3 daily quests generated")

	quest_gen.progress_quest(&"q.purge_mutants", 5, player_data)
	var q: ExpeditionQuestGenerator.Quest = quest_gen.active_quests[&"q.purge_mutants"]
	assert(q.is_completed, "Purge quest completed after 5 kills")

	print("--- All Campsite & Expedition Subsystem Depth Verification Tests Passed! ---")
	queue_free()
