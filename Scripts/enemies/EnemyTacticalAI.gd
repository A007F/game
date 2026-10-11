extends Node
class_name EnemyTacticalAI

## Finds nearest cover position relative to player position
static func find_cover_position(enemy_pos: Vector3, player_pos: Vector3, space_state: PhysicsDirectSpaceState3D, search_radius: float = 12.0) -> Vector3:
	var best_cover := enemy_pos
	var best_score := -999.0

	# Sample 8 cardinal directions around enemy
	for i in range(8):
		var angle := i * (TAU / 8.0)
		var sample_offset := Vector3(cos(angle) * search_radius, 0.0, sin(angle) * search_radius)
		var sample_pos := enemy_pos + sample_offset

		# Raycast from sample position toward player
		var query := PhysicsRayQueryParameters3D.create(sample_pos, player_pos)
		query.collide_with_bodies = true
		query.collide_with_areas = false

		var result := space_state.intersect_ray(query)
		if result:
			# Object blocks line of sight to player -> valid cover!
			var dist_to_enemy := enemy_pos.distance_to(sample_pos)
			var score := 100.0 - dist_to_enemy
			if score > best_score:
				best_score = score
				best_cover = sample_pos

	return best_cover

## Calculates flanking direction vector perpendicular to player's line of sight
static func calculate_flank_vector(enemy_pos: Vector3, player_pos: Vector3, flank_left: bool = true) -> Vector3:
	var to_player := (player_pos - enemy_pos).normalized()
	var perp := Vector3(-to_player.z, 0.0, to_player.x) if flank_left else Vector3(to_player.z, 0.0, -to_player.x)
	return (to_player * 0.5 + perp * 0.8).normalized()
