extends Node
class_name DreamRealmSystem

signal dream_started()
signal dream_completed(success: bool)

var is_in_dream_realm: bool = false
var dream_encounter_count: int = 0

func check_and_trigger_dream(player_data: PlayerData) -> bool:
	if player_data == null:
		return false

	# Trigger dream when sanity is under 40% upon resting
	if player_data.sanity < 40.0 and not is_in_dream_realm:
		start_dream_encounter(player_data)
		return true

	return false

func start_dream_encounter(player_data: PlayerData) -> void:
	is_in_dream_realm = true
	dream_encounter_count += 1
	dream_started.emit()
	GameLog.info("ENTERED DREAM REALM! Confronting memory echoes of Gilead...")

func complete_dream_encounter(success: bool, player_data: PlayerData) -> void:
	if not is_in_dream_realm:
		return

	is_in_dream_realm = false
	dream_completed.emit(success)

	if success:
		GameLog.info("DREAM CONFRONTED! Memory echoes overcome. Sanity restored (+60)!")
		if player_data:
			player_data.restore_sanity(60.0)
			if player_data.skill_tree:
				player_data.skill_tree.add_xp(150) # Award bonus XP
	else:
		GameLog.warn("DREAM NIGHTMARE! Woke up shaken and weary.")
