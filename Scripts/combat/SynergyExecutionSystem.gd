extends Node
class_name SynergyExecutionSystem

signal execution_available(target_enemy: EnemyBase3D)
signal execution_performed(target_enemy: EnemyBase3D, damage_dealt: float)

var active_target: EnemyBase3D = null
var execution_window_timer: float = 0.0

func _process(delta: float) -> void:
	if active_target != null:
		execution_window_timer -= delta
		if execution_window_timer <= 0.0 or not is_instance_valid(active_target) or active_target.current_state == EnemyBase3D.State.DEAD:
			active_target = null

func trigger_companion_trap(enemy: EnemyBase3D, duration: float = 4.0) -> void:
	if enemy == null or enemy.current_state == EnemyBase3D.State.DEAD:
		return

	active_target = enemy
	execution_window_timer = duration
	execution_available.emit(enemy)
	GameLog.info("SYNERGY EXECUTION PROMPT! Press E near %s!" % enemy.data.enemy_name)

func try_execute_finisher(player_node: Node3D, base_damage: float) -> bool:
	if active_target == null or not is_instance_valid(active_target) or active_target.current_state == EnemyBase3D.State.DEAD:
		return false

	if player_node and player_node.global_position.distance_to(active_target.global_position) > 4.0:
		GameLog.info("Too far to perform execution finisher!")
		return false

	var finisher_damage := base_damage * 3.0
	active_target.take_damage(finisher_damage, true)
	execution_performed.emit(active_target, finisher_damage)
	GameLog.info("KA-TET SYNERGY FINISHER EXECUTED! Dealt %.1f damage!" % finisher_damage)

	# Award ammo and sanity
	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if player_data:
		player_data.reserve_ammo += 12
		player_data.restore_sanity(15.0)

	active_target = null
	return true
