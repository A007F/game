extends Node
class_name CameraShake

@export var trauma_reduction_rate: float = 1.2
@export var max_pitch_offset: float = 0.08
@export var max_yaw_offset: float = 0.06

var trauma: float = 0.0
var camera_node: Camera3D = null

func setup(cam: Camera3D) -> void:
	camera_node = cam

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma <= 0.0 or camera_node == null:
		return

	var shake := trauma * trauma # Quadratic curve for natural feel
	var offset_pitch := randf_range(-max_pitch_offset, max_pitch_offset) * shake
	var offset_yaw := randf_range(-max_yaw_offset, max_yaw_offset) * shake

	camera_node.rotation.x += offset_pitch
	camera_node.rotation.y += offset_yaw

	trauma = clamp(trauma - trauma_reduction_rate * delta, 0.0, 1.0)
