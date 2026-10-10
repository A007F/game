extends CharacterBody3D
class_name CompanionBase3D

enum CompanionState { FOLLOW, DEFEND, ATTACK, REST, GATHER }

@export var companion_name: String = "Oy (Billy-Bumbler)"
@export var move_speed: float = 5.5
@export var follow_distance: float = 3.0
@export var attack_damage: float = 20.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.0

var current_state: CompanionState = CompanionState.FOLLOW
var player_node: Node3D = null
var current_target: EnemyBase3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _attack_timer: float = 0.0

func _ready() -> void:
	add_to_group("companions")
	_find_player()

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_attack_timer -= delta

	if player_node == null:
		_find_player()

	_scan_for_enemies()

	match current_state:
		CompanionState.FOLLOW:
			_process_follow(delta)
		CompanionState.ATTACK:
			_process_attack(delta)
		CompanionState.DEFEND:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_node = players[0] as Node3D

func _scan_for_enemies() -> void:
	if current_target != null and is_instance_valid(current_target) and current_target.current_state != EnemyBase3D.State.DEAD:
		return

	current_target = null
	var enemies := get_tree().get_nodes_in_group("enemies")
	var closest_dist := 12.0 # Detection radius

	for enemy in enemies:
		if enemy is EnemyBase3D and enemy.current_state != EnemyBase3D.State.DEAD:
			var dist := global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				current_target = enemy

	if current_target != null:
		current_state = CompanionState.ATTACK

func _process_follow(_delta: float) -> void:
	if player_node == null:
		return

	var dist := global_position.distance_to(player_node.global_position)
	if dist > follow_distance:
		var dir := (player_node.global_position - global_position).normalized()
		dir.y = 0.0
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed

		if dir.length_squared() > 0.001:
			look_at(global_position + dir, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

func _process_attack(_delta: float) -> void:
	if current_target == null or not is_instance_valid(current_target) or current_target.current_state == EnemyBase3D.State.DEAD:
		current_target = null
		current_state = CompanionState.FOLLOW
		return

	var dist := global_position.distance_to(current_target.global_position)
	if dist <= attack_range:
		velocity.x = 0.0
		velocity.z = 0.0
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			current_target.take_damage(attack_damage)
			GameLog.info("%s attacks %s!" % [companion_name, current_target.data.enemy_name])
	else:
		var dir := (current_target.global_position - global_position).normalized()
		dir.y = 0.0
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		if dir.length_squared() > 0.001:
			look_at(global_position + dir, Vector3.UP)

func receive_command(cmd: StringName) -> void:
	match cmd:
		&"cmd.follow":
			current_state = CompanionState.FOLLOW
			GameLog.info("%s is now following player." % companion_name)
		&"cmd.defend":
			current_state = CompanionState.DEFEND
			GameLog.info("%s is defending area." % companion_name)
		&"cmd.attack":
			_scan_for_enemies()
			if current_target != null:
				current_state = CompanionState.ATTACK
			GameLog.info("%s is seeking targets." % companion_name)
		&"cmd.gather":
			current_state = CompanionState.GATHER
			GameLog.info("%s is gathering nearby scrap and ammo!" % companion_name)
