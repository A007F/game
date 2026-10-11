extends Node

func _ready() -> void:
	print("--- Running Combat Subsystem Depth Verification Test ---")

	# 1. Test WeaponAttachmentData & WeaponData
	var weapon_data := WeaponData.new()
	weapon_data.damage = 40.0
	weapon_data.recoil = 0.1

	var scope := WeaponAttachmentData.new()
	scope.damage_multiplier = 1.1
	scope.recoil_multiplier = 0.5
	weapon_data.attachments.append(scope)

	assert(weapon_data.get_effective_damage() == 44.0, "Effective damage should be 44 (40 * 1.1)")
	assert(weapon_data.get_effective_recoil() == 0.05, "Effective recoil should be 0.05 (0.1 * 0.5)")

	# 2. Test Player Dodge Roll & Invulnerability
	var player := Player.new()
	var player_data := PlayerData.new()
	player._player_data = player_data

	player.perform_dodge_roll()
	assert(player.is_rolling, "Player should be rolling")
	player.take_damage(50.0) # Should dodge damage
	assert(player_data.current_health == 100.0, "Player should take 0 damage while rolling")

	# 3. Test CameraShake
	var shake := CameraShake.new()
	shake.add_trauma(0.5)
	assert(shake.trauma == 0.5, "Trauma added successfully")

	print("--- All Combat Subsystem Depth Verification Tests Passed! ---")
	queue_free()
