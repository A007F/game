extends Node
class_name CosmeticAchievementManager

signal achievement_unlocked(achievement_name: String, skin_id: StringName)

var achievements: Dictionary = {
	&"ach.mutant_slayer": { "name": "Mutant Slayer (50 Kills)", "target": 50, "progress": 0, "reward_skin": &"skin.outfit.duster_black", "unlocked": false },
	&"ach.beam_savior": { "name": "Beam Savior (Repair 3 Nodes)", "target": 3, "progress": 0, "reward_skin": &"skin.weapon.beam_runes", "unlocked": false }
}

func progress_achievement(ach_id: StringName, amount: int = 1, store: InGameStore = null) -> void:
	if not achievements.has(ach_id):
		return

	var ach: Dictionary = achievements[ach_id]
	if ach.unlocked:
		return

	ach.progress = min(ach.progress + amount, ach.target)
	GameLog.info("Achievement Progress '%s': %d/%d" % [ach.name, ach.progress, ach.target])

	if ach.progress >= ach.target:
		ach.unlocked = true
		achievement_unlocked.emit(ach.name, ach.reward_skin)
		GameLog.info("ACHIEVEMENT UNLOCKED: '%s'! Unlocked Skin: %s!" % [ach.name, ach.reward_skin])

		if store:
			store.unlocked_cosmetics[ach.reward_skin] = true
			for item in store.catalog:
				if item.id == ach.reward_skin:
					item.is_unlocked = true
					break
