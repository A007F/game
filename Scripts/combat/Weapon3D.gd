extends Node3D
class_name Weapon3D

signal weapon_fired(current_ammo: int, reserve_ammo: int)
signal weapon_reloaded(current_ammo: int, reserve_ammo: int)
signal weapon_empty()

@export var data: WeaponData

var _time_since_last_shot: float = 0.0
var _is_reloading: bool = false
var _reload_timer: float = 0.0

func _ready() -> void:
	if data == null:
		data = WeaponData.new()

func _process(delta: float) -> void:
	_time_since_last_shot += delta

	if _is_reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_finish_reload()

func can_fire(current_ammo: int) -> bool:
	return not _is_reloading and _time_since_last_shot >= data.fire_rate and current_ammo > 0

func try_fire(camera: Camera3D, player_data: PlayerData) -> bool:
	if not can_fire(player_data.current_ammo):
		if player_data.current_ammo <= 0 and not _is_reloading:
			weapon_empty.emit()
			try_reload(player_data)
		return false

	_time_since_last_shot = 0.0
	player_data.current_ammo -= 1

	_perform_raycast_shot(camera)
	weapon_fired.emit(player_data.current_ammo, player_data.reserve_ammo)
	return true

func try_reload(player_data: PlayerData) -> void:
	if _is_reloading or player_data.current_ammo >= data.magazine_capacity or player_data.reserve_ammo <= 0:
		return

	_is_reloading = true
	_reload_timer = data.reload_time
	GameLog.info("Reloading weapon (%s)..." % data.weapon_name)

func _finish_reload() -> void:
	# Assume player_data is passed or synced via owner
	_is_reloading = false
	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if player_data:
		var needed: int = data.magazine_capacity - player_data.current_ammo
		var available: int = min(needed, player_data.reserve_ammo)
		player_data.current_ammo += available
		player_data.reserve_ammo -= available
		weapon_reloaded.emit(player_data.current_ammo, player_data.reserve_ammo)
		GameLog.info("Reload complete. Ammo: %d/%d" % [player_data.current_ammo, player_data.reserve_ammo])

func _perform_raycast_shot(camera: Camera3D) -> void:
	if camera == null:
		return

	var space_state := get_world_3d().direct_space_state
	var viewport_size := camera.get_viewport().get_visible_rect().size
	var screen_center := viewport_size * 0.5

	var ray_origin := camera.project_ray_origin(screen_center)
	var ray_dir := camera.project_ray_normal(screen_center)

	# Apply effective spread and range from attachments
	var eff_spread := data.get_effective_spread() if data.has_method("get_effective_spread") else data.spread
	var eff_range := data.get_effective_range() if data.has_method("get_effective_range") else data.effective_range
	var eff_damage := data.get_effective_damage() if data.has_method("get_effective_damage") else data.damage

	var spread_offset := Vector3(
		randf_range(-eff_spread, eff_spread),
		randf_range(-eff_spread, eff_spread),
		0.0
	)
	ray_dir = (ray_dir + spread_offset).normalized()

	var ray_end := ray_origin + ray_dir * eff_range
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := space_state.intersect_ray(query)
	if result:
		var collider: Object = result.collider
		var final_damage: float = eff_damage
		var is_headshot: bool = false

		# Check relative Y offset for headshots
		if collider is Node3D:
			var rel_height: float = result.position.y - collider.global_position.y
			if rel_height >= 1.2:
				is_headshot = true
				final_damage *= 2.5
				GameLog.info("CRITICAL HEADSHOT DETECTED! Damage: %f" % final_damage)

		GameLog.info("Weapon hit: %s (Headshot: %s) at %s" % [collider.name, str(is_headshot), result.position])

		if collider.has_method("take_damage"):
			collider.take_damage(final_damage, is_headshot)
		elif collider.get_parent() and collider.get_parent().has_method("take_damage"):
			collider.get_parent().take_damage(final_damage, is_headshot)
