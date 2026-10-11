extends Node
class_name CorruptionSystem

signal corruption_level_changed(new_corruption_percent: float)

@export var tower_position: Vector3 = Vector3.ZERO
@export var max_corruption_radius: float = 1000.0 ## Radius in meters where corruption is felt
@export var base_corruption_rate: float = 0.8 ## Base sanity drain rate per second near tower

func calculate_corruption_at_position(world_pos: Vector3) -> float:
	var dist := world_pos.distance_to(tower_position)
	if dist >= max_corruption_radius:
		return 0.0
	var factor := 1.0 - (dist / max_corruption_radius)
	return clamp(factor * 100.0, 0.0, 100.0)

func process_corruption_tick(delta: float, player_data: PlayerData, player_pos: Vector3) -> float:
	if player_data == null:
		return 0.0

	var corruption_percent := calculate_corruption_at_position(player_pos)
	if corruption_percent > 0.0:
		var drain := (corruption_percent / 100.0) * base_corruption_rate * delta
		player_data.drain_sanity(drain)
		corruption_level_changed.emit(corruption_percent)

	return corruption_percent
