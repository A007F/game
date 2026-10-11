extends Node

func _ready() -> void:
	print("--- Running Creative Features Verification Test ---")

	# 1. Test DreamRealmSystem
	var dream_sys := DreamRealmSystem.new()
	var player_data := PlayerData.new()
	player_data.sanity = 30.0 # Low sanity
	var triggered := dream_sys.check_and_trigger_dream(player_data)
	assert(triggered, "Dream should trigger when sanity < 40%")
	assert(dream_sys.is_in_dream_realm, "Should be in dream realm")
	dream_sys.complete_dream_encounter(true, player_data)
	assert(player_data.sanity == 90.0, "Sanity restored to 90 (30 + 60)")

	# 2. Test ShiftingPortalSystem
	var portal_sys := ShiftingPortalSystem.new()
	var door := WaystationDoor3D.new()
	portal_sys.update_door_for_beam_integrity(door, 80.0)
	assert(door.waystation_name.contains("Supply Sanctuary"), "Lush sanctuary destination assigned")

	portal_sys.update_door_for_beam_integrity(door, 20.0)
	assert(door.waystation_name.contains("Corrupted Vault"), "Corrupted vault destination assigned")

	# 3. Test SynergyExecutionSystem
	var synergy_sys := SynergyExecutionSystem.new()
	var dummy_enemy := EnemyBase3D.new()
	synergy_sys.trigger_companion_trap(dummy_enemy)
	assert(synergy_sys.active_target == dummy_enemy, "Dummy enemy trapped for execution")

	# 4. Test OldWorldRadio
	var radio := OldWorldRadio.new()
	radio.toggle_radio()
	assert(radio.is_playing, "Radio should be playing")
	radio.toggle_radio()
	assert(not radio.is_playing, "Radio should be stopped")

	# 5. Test CampfireRelicData
	var relic := CampfireRelicData.new()
	var camp := Campsite3D.new()
	camp.active_relic = relic
	assert(camp.active_relic.heal_multiplier == 1.5, "Campfire relic heal multiplier verified")

	# 6. Test BeamNodeMinigame
	var minigame := BeamNodeMinigame.new()
	minigame.start_minigame("Node Beta")
	minigame.current_frequency = 430.0
	var success := minigame.adjust_frequency(2.0)
	assert(success, "Beam node puzzle aligned and solved")

	print("--- All Creative Features Verification Tests Passed Successfully! ---")
	queue_free()
