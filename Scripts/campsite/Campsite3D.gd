extends Node3D
class_name Campsite3D

signal campsite_rested()

@export var camp_name: String = "Waystation Campsite"
@export var comfort_radius: float = 8.0
@export var health_regen_per_sec: float = 2.0
@export var sanity_regen_per_sec: float = 3.0
@export var is_fire_lit: bool = true

func _process(delta: float) -> void:
	if not is_fire_lit:
		return

	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if player_data == null:
		return

	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player_node := players[0] as Node3D
		if global_position.distance_to(player_node.global_position) <= comfort_radius:
			player_data.heal(health_regen_per_sec * delta)
			player_data.restore_sanity(sanity_regen_per_sec * delta)

func rest_at_camp() -> void:
	var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
	if player_data:
		player_data.heal(50.0)
		player_data.restore_sanity(50.0)
		campsite_rested.emit()
		GameLog.info("Rested at %s. Health and Sanity restored!" % camp_name)
