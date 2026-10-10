extends Resource
class_name PlayerData

@export var player_id: StringName = &"player.main"
@export var has_world_transform: bool = false
@export var world_position: Vector3 = Vector3.ZERO
@export var world_yaw_radians: float = 0.0
@export var active_vehicle_id: StringName = &""

# Survival & Combat stats (headless — ticked by SimulationCore independently of 3D puppet)
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var max_sanity: float = 100.0
@export var sanity: float = 100.0

@export var max_calories: float = 1000.0
@export var max_hydration: float = 100.0
@export var max_energy: float = 100.0
@export var calories: float = 1000.0
@export var hydration: float = 100.0
@export var energy: float = 100.0

# Ammo tracking for equipped weapon
@export var current_ammo: int = 6
@export var reserve_ammo: int = 36

# Inventory system (UESS: ID-based, no ItemInstance references)
var pockets: InventoryData = InventoryData.new()
var equipment_back: StringName = &"" ## runtime_id of equipped backpack EntityData (has ContainerComponent)

func _init() -> void:
	# Default pocket settings
	pockets.max_volume = 2.0
	pockets.max_mass = 5.0

func get_total_encumbrance_mass() -> float:
	var total: float = pockets.get_current_mass()
	if equipment_back != &"" and GameManager.session and GameManager.session.entities:
		var backpack := GameManager.session.entities.get_entity(equipment_back)
		if backpack:
			var item_comp := backpack.get_component(&"item") as ItemComponent
			if item_comp:
				total += item_comp.mass_kg
			# If the backpack has its own inventory (ContainerComponent), 
			# that weight would be tracked inside its own InventoryData.
	return total

# Property getters/setters
var stamina: float:
	get: return energy
	set(value): energy = value
var health: float:
	get: return current_health
	set(value): current_health = clamp(value, 0.0, max_health)

func set_transform(position: Vector3, yaw_radians: float) -> void:
	has_world_transform = true
	world_position = position
	world_yaw_radians = yaw_radians

var skill_tree: SkillTree = SkillTree.new()

func take_damage(amount: float) -> void:
	current_health = clamp(current_health - amount, 0.0, max_health)

func heal(amount: float) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)

func drain_sanity(amount: float) -> void:
	var actual_drain: float = amount
	if skill_tree and skill_tree.has_perk(&"iron_will"):
		actual_drain *= 0.7 # 30% reduction from Iron Will perk
	sanity = clamp(sanity - actual_drain, 0.0, max_sanity)

func restore_sanity(amount: float) -> void:
	sanity = clamp(sanity + amount, 0.0, max_sanity)

func tick_survival_minute() -> void:
	calories = clamp(calories - 0.1, 0.0, max_calories)
	hydration = clamp(hydration - 0.05, 0.0, max_hydration)
	energy = clamp(energy - 0.02, 0.0, max_energy)
	# Slight sanity decay during dark hours or extreme hunger
	if calories < 100.0 or hydration < 10.0:
		drain_sanity(0.2)

func burn_energy(delta: float) -> void:
	energy = clamp(energy - 10.0 * delta, 0.0, max_energy)
	calories = clamp(calories - 2.0 * delta, 0.0, max_calories)
