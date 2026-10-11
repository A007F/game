extends Node3D
class_name BulletDecal

@export var lifetime: float = 10.0

func _ready() -> void:
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

static func spawn_at(world_tree: SceneTree, position: Vector3, normal: Vector3) -> BulletDecal:
	var decal := BulletDecal.new()
	decal.global_position = position
	if normal.length_squared() > 0.001:
		decal.look_at(position + normal, Vector3.UP if abs(normal.y) < 0.99 else Vector3.FORWARD)

	if world_tree and world_tree.current_scene:
		world_tree.current_scene.add_child(decal)
	return decal
