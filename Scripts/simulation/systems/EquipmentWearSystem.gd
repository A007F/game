extends Node
class_name EquipmentWearSystem

signal equipment_repaired(equipment_name: String)
signal equipment_broken(equipment_name: String)

func apply_generator_wear(generator: GeneratorDefinition, delta_minutes: float) -> void:
	if generator == null or generator.current_condition_percent <= 0.0:
		return

	var wear := generator.wear_rate_per_minute * delta_minutes
	generator.current_condition_percent = clamp(generator.current_condition_percent - wear, 0.0, 100.0)

	if generator.current_condition_percent <= 0.0:
		equipment_broken.emit(generator.generator_name)
		GameLog.warn("Generator %s has broken down due to wear!" % generator.generator_name)

func apply_equipment_corrosion(equipment: ExpeditionEquipmentData, corruption_percent: float, delta_seconds: float) -> void:
	if equipment == null or equipment.current_durability <= 0.0:
		return

	var resistance_factor := 1.0 - clamp(equipment.corrosion_resistance, 0.0, 0.9)
	var corrosion_damage := (corruption_percent / 100.0) * 0.5 * resistance_factor * delta_seconds
	equipment.current_durability = clamp(equipment.current_durability - corrosion_damage, 0.0, equipment.max_durability)

	if equipment.current_durability <= 0.0:
		equipment_broken.emit(equipment.equipment_name)
		GameLog.warn("Expedition Equipment %s corroded completely!" % equipment.equipment_name)

func repair_equipment(equipment: ExpeditionEquipmentData, amount: float) -> void:
	if equipment == null:
		return
	equipment.current_durability = clamp(equipment.current_durability + amount, 0.0, equipment.max_durability)
	equipment_repaired.emit(equipment.equipment_name)
	GameLog.info("Repaired %s (+%.1f durability)" % [equipment.equipment_name, amount])
