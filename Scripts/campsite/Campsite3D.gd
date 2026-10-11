extends Node3D
class_name Campsite3D

signal campsite_rested()

@export var camp_name: String = "Waystation Campsite"
@export var comfort_radius: float = 8.0
@export var health_regen_per_sec: float = 2.0
@export var sanity_regen_per_sec: float = 3.0
@export var is_fire_lit: bool = true
@export var active_relic: CampfireRelicData = null
@export var barricade_level: int = 1 ## Barricade level 1, 2, or 3

var workbench: CampWorkbench = CampWorkbench.new()

func upgrade_barricade() -> bool:
	if barricade_level >= 3:
		GameLog.info("Camp barricades are already at maximum level 3!")
		return false

	barricade_level += 1
	comfort_radius += 3.0
	health_regen_per_sec += 1.0
	GameLog.info("UPGRADED CAMP BARRICADES to Level %d! Comfort radius expanded to %.1fm!" % [barricade_level, comfort_radius])
	return true

func _process(delta: float) -> void:
	if not is_fire_lit:
		return

	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if player_data == null:
		return

	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player_node := players[0] as Node3D
		var effective_radius := comfort_radius
		var h_regen := health_regen_per_sec
		var s_regen := sanity_regen_per_sec

		if active_relic:
			effective_radius = active_relic.repellent_radius
			h_regen *= active_relic.heal_multiplier
			s_regen *= active_relic.sanity_multiplier

		if global_position.distance_to(player_node.global_position) <= effective_radius:
			player_data.heal(h_regen * delta)
			player_data.restore_sanity(s_regen * delta)

func rest_at_camp() -> void:
	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if player_data:
		player_data.heal(50.0)
		player_data.restore_sanity(50.0)
		campsite_rested.emit()
		GameLog.info("Rested at %s. Health and Sanity restored!" % camp_name)
