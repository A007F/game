extends Node
class_name BeamStormManager

signal storm_started()
signal storm_ended()

@export var storm_interval_seconds: float = 300.0 ## Seconds between storms
@export var storm_duration_seconds: float = 60.0  ## Duration of anomaly storm
@export var sanity_drain_per_second: float = 1.5

var is_storm_active: bool = false
var _timer: float = 0.0

func _process(delta: float) -> void:
	_timer += delta

	if not is_storm_active:
		if _timer >= storm_interval_seconds:
			start_storm()
	else:
		if _timer >= storm_duration_seconds:
			end_storm()
		else:
			_process_storm_effects(delta)

func start_storm() -> void:
	is_storm_active = true
	_timer = 0.0
	storm_started.emit()
	GameLog.info("WARNING: Beam Anomaly Storm started! Seek shelter or light lanterns!")

func end_storm() -> void:
	is_storm_active = false
	_timer = 0.0
	storm_ended.emit()
	GameLog.info("Beam Anomaly Storm ended. Weather cleared.")

func _process_storm_effects(delta: float) -> void:
	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if player_data == null:
		return

	# Drain sanity unless inside campsite comfort zone
	var in_safe_zone := false
	var camps := get_tree().get_nodes_in_group("campsites")
	var players := get_tree().get_nodes_in_group("player")

	if players.size() > 0:
		var p_node := players[0] as Node3D
		for camp in camps:
			if camp is Campsite3D and camp.global_position.distance_to(p_node.global_position) <= camp.comfort_radius:
				in_safe_zone = true
				break

	if not in_safe_zone:
		player_data.drain_sanity(sanity_drain_per_second * delta)
