extends Node

func _ready() -> void:
	print("--- Running Enemy AI Subsystem Depth Verification Test ---")

	# 1. Test EnemyTacticalAI
	var flank_v := EnemyTacticalAI.calculate_flank_vector(Vector3.ZERO, Vector3(10, 0, 0), true)
	assert(flank_v.length_squared() > 0.0, "Flank vector calculated")

	# 2. Test BossEnemy3D Phase Transition
	var boss := BossEnemy3D.new()
	assert(boss.current_phase == 1, "Boss starts in Phase 1")
	boss.take_damage(300.0) # 300 damage out of 500 max health
	assert(boss.current_phase == 2, "Boss transitioned to Phase 2 at 50% HP")
	assert(boss.is_invulnerable, "Boss shield pulse activated during phase shift")

	# 3. Test EnemySquadManager Alarm Countdown
	var squad_mgr := EnemySquadManager.new()
	var scout := EnemyBase3D.new()
	squad_mgr.broadcast_player_spotted(scout, Vector3(5, 0, 5))
	assert(squad_mgr.is_squad_alerted, "Squad alerted by scout")
	assert(squad_mgr.alarm_scout == scout, "Alarm scout registered")

	print("--- All Enemy AI Subsystem Depth Verification Tests Passed! ---")
	queue_free()
