extends Resource
class_name EnemyData

@export var enemy_name: String = "Slow Mutant"
@export var max_health: float = 80.0
@export var move_speed: float = 3.5
@export var chase_speed: float = 5.0
@export var attack_damage: float = 15.0
@export var attack_range: float = 1.8
@export var attack_cooldown: float = 1.2
@export var detection_radius: float = 15.0
@export var sanity_aura_drain: float = 0.5 ## Sanity drain per second when near player
