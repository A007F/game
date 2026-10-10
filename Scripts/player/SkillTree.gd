extends Node
class_name SkillTree

signal level_up(new_level: int, skill_points: int)
signal perk_unlocked(perk_id: StringName)

var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
var skill_points: int = 0

var perks: Dictionary = {
	&"fan_the_hammer": false, # Rapid hip-fire burst
	&"iron_will": false,       # 30% reduced sanity drain
	&"quick_reload": false,     # 35% faster reloads
	&"bounty_hunter": false     # +25% scrap marks rewards
}

func add_xp(amount: int) -> void:
	current_xp += amount
	GameLog.info("Gained %d XP (Total: %d/%d)" % [amount, current_xp, xp_to_next_level])

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		skill_points += 1
		xp_to_next_level = int(xp_to_next_level * 1.5)
		level_up.emit(level, skill_points)
		GameLog.info("LEVELED UP! Reached Level %d! (+1 Skill Point)" % level)

func unlock_perk(perk_id: StringName) -> bool:
	if not perks.has(perk_id):
		GameLog.warn("Invalid perk ID: %s" % perk_id)
		return false

	if perks[perk_id]:
		GameLog.info("Perk %s is already unlocked." % perk_id)
		return false

	if skill_points < 1:
		GameLog.warn("Not enough skill points to unlock %s!" % perk_id)
		return false

	skill_points -= 1
	perks[perk_id] = true
	perk_unlocked.emit(perk_id)
	GameLog.info("Unlocked Perk: %s!" % perk_id)
	return true

func has_perk(perk_id: StringName) -> bool:
	return perks.get(perk_id, false)
