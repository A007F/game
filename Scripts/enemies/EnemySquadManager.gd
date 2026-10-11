extends Node
class_name EnemySquadManager

signal squad_alerted(scout_name: String)
signal alarm_sounded(wave_count: int)

@export var alert_radius: float = 25.0
@export var alarm_countdown_seconds: float = 3.5

var is_squad_alerted: bool = false
var alarm_scout: EnemyBase3D = null
var _alarm_timer: float = 0.0

func broadcast_player_spotted(scout: EnemyBase3D, player_pos: Vector3) -> void:
	if scout == null or scout.current_state == EnemyBase3D.State.DEAD:
		return

	if not is_squad_alerted:
		is_squad_alerted = true
		alarm_scout = scout
		_alarm_timer = alarm_countdown_seconds
		squad_alerted.emit(scout.data.enemy_name)
		GameLog.info("SQUAD ALERT! %s spotted player! Alarm countdown: %.1f sec!" % [scout.data.enemy_name, alarm_countdown_seconds])

		# Alert nearby enemies in radius
		var enemies := get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if enemy is EnemyBase3D and enemy.current_state != EnemyBase3D.State.DEAD:
				if enemy.global_position.distance_to(scout.global_position) <= alert_radius:
					enemy.current_state = EnemyBase3D.State.CHASE

func _process(delta: float) -> void:
	if is_squad_alerted and alarm_scout != null:
		if not is_instance_valid(alarm_scout) or alarm_scout.current_state == EnemyBase3D.State.DEAD:
			# Scout killed before alarm sounded!
			is_squad_alerted = false
			alarm_scout = null
			GameLog.info("ALARM PREVENTED! Scout eliminated in time!")
			return

		_alarm_timer -= delta
		if _alarm_timer <= 0.0:
			_sound_alarm()

func _sound_alarm() -> void:
	is_squad_alerted = false
	alarm_sounded.emit(4)
	GameLog.warn("ALARM SOUNDED! Wave reinforcements incoming!")

	if alarm_scout:
		var spawners := get_tree().get_nodes_in_group("wave_spawners")
		for spawner in spawners:
			if spawner is WaveSpawner:
				spawner.start_wave(4, alarm_scout.global_position)
				break
	alarm_scout = null
