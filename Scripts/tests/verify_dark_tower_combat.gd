extends Node

func _ready() -> void:
	print("--- Running Dark Tower Combat Verification Test ---")

	# Test PlayerData combat & sanity stats
	var player_data := PlayerData.new()
	assert(player_data.max_health == 100.0, "Max health should be 100")
	assert(player_data.sanity == 100.0, "Initial sanity should be 100")

	player_data.take_damage(25.0)
	assert(player_data.current_health == 75.0, "Current health should be 75 after 25 damage")

	player_data.drain_sanity(15.0)
	assert(player_data.sanity == 85.0, "Sanity should be 85 after 15 drain")

	player_data.restore_sanity(10.0)
	assert(player_data.sanity == 95.0, "Sanity should be 95 after restore")

	# Test WeaponData
	var revolver_data := WeaponData.new()
	revolver_data.weapon_name = "Custom Revolver"
	revolver_data.damage = 50.0
	assert(revolver_data.damage == 50.0, "Weapon damage should match set value")

	# Test EnemyData
	var mutant_data := EnemyData.new()
	mutant_data.enemy_name = "Slow Mutant"
	mutant_data.max_health = 100.0
	assert(mutant_data.max_health == 100.0, "Enemy max health verified")

	print("--- All Dark Tower Combat Verification Tests Passed Successfully! ---")
	queue_free()
