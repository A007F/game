extends Resource
class_name TowerLevelResource

@export var level_index: int = 1
@export var level_title: String = "Waystation Threshold"
@export var corruption_intensity: float = 15.0 ## Corruption percentage on this level (0.0 to 100.0)
@export var beam_integrity_percent: float = 85.0 ## Beam stability percentage
@export var scrap_reward_multiplier: float = 1.25 ## Multiplier for scrap tokens earned
@export var unlocked_by_default: bool = false
@export var level_description: String = "The outer ring of Mid-World. Low corruption, active waystation portals."
