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
