extends Node
class_name BeamNodeMinigame

signal minigame_completed(node_name: String, success: bool)

var is_active: bool = false
var node_name: String = "Beam Node Alpha"
var target_frequency: float = 432.0 ## Hz
var current_frequency: float = 380.0
var frequency_tolerance: float = 5.0

func start_minigame(p_node_name: String) -> void:
	node_name = p_node_name
	is_active = true
	current_frequency = randf_range(350.0, 400.0)
	GameLog.info("BEAM REPAIR MINIGAME STARTED! Align frequency to %.1f Hz (Current: %.1f Hz)" % [target_frequency, current_frequency])

func adjust_frequency(amount: float) -> bool:
	if not is_active:
		return false

	current_frequency += amount
	GameLog.info("Tuned frequency: %.1f Hz (Target: %.1f Hz)" % [current_frequency, target_frequency])

	if abs(current_frequency - target_frequency) <= frequency_tolerance:
		is_active = false
		minigame_completed.emit(node_name, true)
		GameLog.info("BEAM NODE REPAIRED! Local corruption purged!")
		return true

	return false
