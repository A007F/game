extends Node

func _ready() -> void:
	print("--- Running Core Refactoring & Custom Resources Verification Test ---")

	# 1. Test GeneratorDefinition & ExpeditionEquipmentData
	var gen := GeneratorDefinition.new()
	gen.generator_name = "Beam Generator Alpha"
	gen.wear_rate_per_minute = 1.0
	assert(gen.power_output_kw == 120.0, "Generator power output verified")

	var eq := ExpeditionEquipmentData.new()
	eq.equipment_name = "Anomaly Scanner"
	assert(eq.corrosion_resistance == 0.8, "Equipment corrosion resistance verified")

	# 2. Test CorruptionSystem
	var corruption_sys := CorruptionSystem.new()
	corruption_sys.tower_position = Vector3.ZERO
	corruption_sys.max_corruption_radius = 1000.0

	var corr_at_center := corruption_sys.calculate_corruption_at_position(Vector3.ZERO)
	assert(corr_at_center == 100.0, "Corruption at Tower center should be 100%")

	var corr_at_500m := corruption_sys.calculate_corruption_at_position(Vector3(500, 0, 0))
	assert(corr_at_500m == 50.0, "Corruption at 500m should be 50%")

	# 3. Test EquipmentWearSystem
	var wear_sys := EquipmentWearSystem.new()
	wear_sys.apply_generator_wear(gen, 10.0) # 10 minutes
	assert(gen.current_condition_percent == 90.0, "Generator condition should be 90% (100 - 10)")

	wear_sys.repair_equipment(eq, 20.0)
	assert(eq.current_durability == 100.0, "Equipment durability clamped at max 100")

	# 4. Test AllianceMemberResource & TowerLevelResource
	var roland := AllianceMemberResource.new()
	assert(roland.member_name == "Roland Deschain", "Alliance member name verified")

	var level1 := TowerLevelResource.new()
	assert(level1.level_index == 1, "Tower level index verified")
	assert(level1.scrap_reward_multiplier == 1.25, "Tower reward multiplier verified")

	print("--- All Core Refactoring & Custom Resources Verification Tests Passed! ---")
	queue_free()
