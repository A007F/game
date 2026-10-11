extends Resource
class_name CompanionData

@export var companion_id: StringName = &"comp.oy"
@export var companion_name: String = "Oy (Billy-Bumbler)"
@export var archetype: String = "SCOUT" ## SCOUT, TANK, SNIPER
@export var move_speed: float = 6.0
@export var attack_damage: float = 22.0
@export var max_health: float = 120.0
@export var unique_synergy_buff: String = "Auto-Looting & Emergency Triage Support"
@export var portrait_texture: Texture2D = null
