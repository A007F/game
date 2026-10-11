extends Resource
class_name GeneratorDefinition

@export var generator_id: StringName = &"gen.standard"
@export var generator_name: String = "Standard Beam Generator"
@export var power_output_kw: float = 120.0
@export var fuel_consumption_rate: float = 2.5 ## Fuel units consumed per operational hour
@export var max_fuel_capacity: float = 100.0
@export var wear_rate_per_minute: float = 0.5 ## Mechanical degradation percentage per minute
@export var current_condition_percent: float = 100.0
