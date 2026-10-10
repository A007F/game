extends Node3D
class_name Projectile3D

@export var speed: float = 60.0
@export var damage: float = 35.0
@export var max_lifetime: float = 3.0
@export var gravity_influence: float = 0.0

var _direction: Vector3 = Vector3.FORWARD
var _lifetime: float = 0.0
var _owner_node: Node = null

func setup(dir: Vector3, proj_damage: float, proj_owner: Node = null) -> void:
	_direction = dir.normalized()
	damage = proj_damage
	_owner_node = proj_owner

func _physics_process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= max_lifetime:
		queue_free()
		return

	if gravity_influence > 0.0:
		_direction.y -= gravity_influence * delta
		_direction = _direction.normalized()

	var move_dist := speed * delta
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + _direction * move_dist)

	if _owner_node is CollisionObject3D:
		query.exclude = [_owner_node.get_rid()]

	var result := space_state.intersect_ray(query)
	if result:
		global_position = result.position
		var collider: Object = result.collider
		if collider.has_method("take_damage"):
			collider.take_damage(damage)
		elif collider.get_parent() and collider.get_parent().has_method("take_damage"):
			collider.get_parent().take_damage(damage)
		queue_free()
	else:
		global_position += _direction * move_dist
