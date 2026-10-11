extends Resource
class_name ExpeditionEquipmentData

@export var equipment_id: StringName = &"eq.scanner"
@export var equipment_name: String = "Beam Anomaly Scanner"
@export var max_durability: float = 100.0
@export var current_durability: float = 100.0
@export var corrosion_resistance: float = 0.8 ## Multiplier reducing corruption wear (0.0 to 1.0)
@export var power_required_kw: float = 15.0
@export var description: String = "Scans surrounding area for Beam energy anomalies and waystation doors."
