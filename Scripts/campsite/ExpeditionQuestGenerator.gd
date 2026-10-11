extends Node
class_name ExpeditionQuestGenerator

signal quest_completed(quest_title: String, reward_scrap: int)

class Quest:
	var id: StringName
	var title: String
	var description: String
	var target_count: int
	var current_progress: int = 0
	var reward_scrap: int
	var reward_xp: int
	var is_completed: bool = false

	func _init(p_id: StringName, p_title: String, p_desc: String, p_target: int, p_scrap: int, p_xp: int) -> void:
		id = p_id
		title = p_title
		description = p_desc
		target_count = p_target
		reward_scrap = p_scrap
		reward_xp = p_xp

var active_quests: Dictionary = {} # StringName -> Quest

func generate_daily_quests() -> void:
	active_quests.clear()

	var q1 := Quest.new(&"q.purge_mutants", "Purge Sector 4 Mutants", "Eliminate 5 Slow Mutants in Sector 4.", 5, 100, 150)
	var q2 := Quest.new(&"q.collect_tech", "Scavenge Old Tech Scrap", "Collect 30 units of Old Ones tech scrap.", 30, 120, 200)
	var q3 := Quest.new(&"q.repair_node", "Restore Beam Node Alpha", "Align circuit frequencies and repair Beam Node Alpha.", 1, 150, 250)

	active_quests[q1.id] = q1
	active_quests[q2.id] = q2
	active_quests[q3.id] = q3
	GameLog.info("Generated 3 new Expedition Quests on the Camp Notice Board!")

func progress_quest(quest_id: StringName, amount: int = 1, player_data: PlayerData = null) -> void:
	if not active_quests.has(quest_id):
		return

	var q: Quest = active_quests[quest_id]
	if q.is_completed:
		return

	q.current_progress = min(q.current_progress + amount, q.target_count)
	GameLog.info("Quest Progress '%s': %d/%d" % [q.title, q.current_progress, q.target_count])

	if q.current_progress >= q.target_count:
		q.is_completed = true
		quest_completed.emit(q.title, q.reward_scrap)
		GameLog.info("QUEST COMPLETED: '%s'! Reward: +%d Scrap Marks, +%d XP!" % [q.title, q.reward_scrap, q.reward_xp])

		if player_data and player_data.skill_tree:
			player_data.skill_tree.add_xp(q.reward_xp)
