extends Node

func _ready() -> void:
	print("--- Running Companion Subsystem Depth Verification Test ---")

	# 1. Test CompanionData Custom Resource
	var comp_data := CompanionData.new()
	assert(comp_data.companion_name.contains("Oy"), "Companion name verified")
	assert(comp_data.archetype == "SCOUT", "Archetype SCOUT verified")

	# 2. Test CompanionLoyaltySystem
	var loyalty_sys := CompanionLoyaltySystem.new()
	assert(loyalty_sys.bond_level == 1, "Initial bond level is 1")
	assert(not loyalty_sys.is_triage_unlocked(), "Triage locked at level 1")

	loyalty_sys.add_loyalty_xp(100)
	assert(loyalty_sys.bond_level == 2, "Bond level 2 reached after 100 XP")

	loyalty_sys.add_loyalty_xp(160)
	assert(loyalty_sys.bond_level == 3, "Bond level 3 reached after 160 XP")
	assert(loyalty_sys.is_triage_unlocked(), "Emergency Triage unlocked at level 3")

	# 3. Test CompanionBase3D & Emergency Triage
	var companion := CompanionBase3D.new()
	companion.loyalty_system = loyalty_sys
	var player_data := PlayerData.new()
	player_data.current_health = 20.0 # Low HP trigger

	companion._check_emergency_triage()
	assert(player_data.current_health == 55.0, "Player healed to 55 HP (20 + 35) by companion emergency triage")

	print("--- All Companion Subsystem Depth Verification Tests Passed! ---")
	queue_free()
