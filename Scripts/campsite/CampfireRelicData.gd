extends Resource
class_name CampfireRelicData

@export var relic_id: StringName = &"relic.beam_blue"
@export var relic_name: String = "Beam Crystal Relic"
@export var flame_color: Color = Color(0.2, 0.6, 1.0, 1.0) ## Mystical blue flame
@export var heal_multiplier: float = 1.5
@export var sanity_multiplier: float = 2.0
@export var repellent_radius: float = 12.0 ## Distance that keeps Slow Mutants at bay
