extends Node
class_name ShiftingPortalSystem

signal portal_shifted(door_name: String, new_destination: String)

func update_door_for_beam_integrity(door: WaystationDoor3D, beam_integrity_percent: float) -> void:
	if door == null:
		return

	if beam_integrity_percent >= 70.0:
		door.waystation_name = "Waystation Haven (Lush Supply Sanctuary)"
		door.target_coordinates = Vector3(200.0, 0.0, 200.0)
		door.requires_beam_key = false
		portal_shifted.emit(door.name, door.waystation_name)
		GameLog.info("Portal shifted to Safe Supply Haven (Beam Integrity: %.1f%%)" % beam_integrity_percent)
	elif beam_integrity_percent < 40.0:
		door.waystation_name = "Corrupted Vault (High Threat & Ancient Tech)"
		door.target_coordinates = Vector3(-450.0, -15.0, -450.0)
		door.requires_beam_key = true
		portal_shifted.emit(door.name, door.waystation_name)
		GameLog.warn("Portal shifted to Corrupted Vault! High danger! (Beam Integrity: %.1f%%)" % beam_integrity_percent)
	else:
		door.waystation_name = "Standard Mid-World Waystation"
		door.target_coordinates = Vector3(100.0, 0.0, 100.0)
		door.requires_beam_key = false
