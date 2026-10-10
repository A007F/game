extends Node
class_name WaveSpawner

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

@export var enemy_scene: PackedScene = null
@export var spawn_radius_min: float = 20.0
@export var spawn_radius_max: float = 35.0

var current_wave: int = 0
var active_enemies: Array[EnemyBase3D] = []
var is_wave_active: bool = false

func start_wave(count: int, center_position: Vector3) -> void:
	if is_wave_active:
		return

	current_wave += 1
	is_wave_active = true
	wave_started.emit(current_wave)
	GameLog.info("Starting Wave #%d with %d enemies!" % [current_wave, count])

	for i in range(count):
		_spawn_single_enemy(center_position)

func _spawn_single_enemy(center_pos: Vector3) -> void:
	var angle := randf() * TAU
	var dist := randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_pos := center_pos + Vector3(cos(angle) * dist, 1.0, sin(angle) * dist)

	var enemy: EnemyBase3D = null
	if enemy_scene:
		enemy = enemy_scene.instantiate() as EnemyBase3D
	else:
		enemy = EnemyBase3D.new()

	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
	active_enemies.append(enemy)
	enemy.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy: EnemyBase3D) -> void:
	active_enemies.erase(enemy)
	if active_enemies.is_empty() and is_wave_active:
		is_wave_active = false
		wave_completed.emit(current_wave)
		GameLog.info("Wave #%d Completed!" % current_wave)
