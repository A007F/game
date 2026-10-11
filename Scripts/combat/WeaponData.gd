extends Resource
class_name WeaponData

@export var weapon_name: String = "Revolver"
@export var damage: float = 35.0
@export var fire_rate: float = 0.4 ## Cooldown between shots in seconds
@export var magazine_capacity: int = 6
@export var reload_time: float = 2.2 ## Seconds required to reload
@export var effective_range: float = 50.0 ## Raycast distance in meters
@export var recoil: float = 0.04 ## Camera pitch kick per shot
@export var spread: float = 0.015 ## Bullet spread angle randomness
@export var ammo_type: StringName = &"ammo.revolver"
@export var is_automatic: bool = false
@export var weapon_mesh: PackedScene = null
@export var attachments: Array[WeaponAttachmentData] = []

func get_effective_damage() -> float:
	var mult: float = 1.0
	for att in attachments:
		if att: mult *= att.damage_multiplier
	return damage * mult

func get_effective_recoil() -> float:
	var mult: float = 1.0
	for att in attachments:
		if att: mult *= att.recoil_multiplier
	return recoil * mult

func get_effective_range() -> float:
	var mult: float = 1.0
	for att in attachments:
		if att: mult *= att.range_multiplier
	return effective_range * mult

func get_effective_spread() -> float:
	var mult: float = 1.0
	for att in attachments:
		if att: mult *= att.spread_multiplier
	return spread * mult
