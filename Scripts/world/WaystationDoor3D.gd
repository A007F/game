extends Node3D
class_name WaystationDoor3D

signal door_entered(target_waystation: String)

@export var waystation_name: String = "Door to Gilead Ruins"
@export var target_coordinates: Vector3 = Vector3(100, 0, 100)
@export var requires_beam_key: bool = false
@export var is_unlocked: bool = true

func try_enter_door(player_node: Node3D) -> bool:
	if not is_unlocked:
		GameLog.warn("Door is locked! Requires Beam Key.")
		return false

	GameLog.info("Entering Dimensional Door: %s!" % waystation_name)
	if player_node:
		player_node.global_position = target_coordinates
		door_entered.emit(waystation_name)
	return true
