extends CharacterBody3D
class_name EnemyBase3D

signal enemy_died(enemy: EnemyBase3D)

enum State { IDLE, PATROL, CHASE, ATTACK, TAKE_COVER, FLANK, DEAD }

@export var data: EnemyData
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D if has_node("NavigationAgent3D") else null

var current_state: State = State.IDLE
var current_health: float = 80.0
var target_node: Node3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _attack_timer: float = 0.0

func _ready() -> void:
	if data == null:
		data = EnemyData.new()
	current_health = data.max_health
	add_to_group("enemies")

var _cover_pos: Vector3 = Vector3.ZERO
var _use_left_flank: bool = true

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	_apply_gravity(delta)
	_update_target()
	_attack_timer -= delta

	match current_state:
		State.IDLE:
			if target_node and _distance_to_target() <= data.detection_radius:
				current_state = State.CHASE
		State.CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)
		State.TAKE_COVER:
			_process_take_cover(delta)
		State.FLANK:
			_process_flank(delta)

	move_and_slide()

func _process_take_cover(_delta: float) -> void:
	if _cover_pos.distance_to(global_position) < 1.0:
		current_state = State.ATTACK
		return
	var dir := (_cover_pos - global_position).normalized()
	dir.y = 0.0
	velocity.x = dir.x * data.chase_speed
	velocity.z = dir.z * data.chase_speed

func _process_flank(_delta: float) -> void:
	if target_node == null:
		current_state = State.IDLE
		return
	var flank_dir := EnemyTacticalAI.calculate_flank_vector(global_position, target_node.global_position, _use_left_flank)
	velocity.x = flank_dir.x * data.chase_speed
	velocity.z = flank_dir.z * data.chase_speed
	if _distance_to_target() <= data.attack_range:
		current_state = State.ATTACK

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _update_target() -> void:
	if target_node == null:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_node = players[0] as Node3D

func _distance_to_target() -> float:
	if target_node == null:
		return 9999.0
	return global_position.distance_to(target_node.global_position)

func _process_chase(delta: float) -> void:
	if target_node == null:
		current_state = State.IDLE
		return

	var dist := _distance_to_target()
	if dist <= data.attack_range:
		current_state = State.ATTACK
		velocity.x = 0.0
		velocity.z = 0.0
		return
	elif dist > data.detection_radius * 1.5:
		current_state = State.IDLE
		velocity.x = 0.0
		velocity.z = 0.0
		return

	# Move toward target
	var dir := (target_node.global_position - global_position).normalized()
	dir.y = 0.0
	velocity.x = dir.x * data.chase_speed
	velocity.z = dir.z * data.chase_speed

	# Face movement direction
	if dir.length_squared() > 0.001:
		look_at(global_position + dir, Vector3.UP)

	# Drain player sanity if near
	if dist <= 5.0:
		var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
		if player_data:
			player_data.drain_sanity(data.sanity_aura_drain * delta)

func _process_attack(_delta: float) -> void:
	if target_node == null:
		current_state = State.IDLE
		return

	var dist := _distance_to_target()
	if dist > data.attack_range * 1.2:
		current_state = State.CHASE
		return

	# Face target
	var dir := (target_node.global_position - global_position).normalized()
	dir.y = 0.0
	if dir.length_squared() > 0.001:
		look_at(global_position + dir, Vector3.UP)

	if _attack_timer <= 0.0:
		_attack_timer = data.attack_cooldown
		_perform_attack()

func _perform_attack() -> void:
	GameLog.info("%s attacks target for %f damage!" % [data.enemy_name, data.attack_damage])
	if target_node and target_node.has_method("take_damage"):
		target_node.take_damage(data.attack_damage)
	else:
		var player_data: PlayerData = GameManager.session.entities.get_player(&"player.main") if GameManager.session else null
		if player_data:
			player_data.take_damage(data.attack_damage)

func take_damage(amount: float, is_headshot: bool = false) -> void:
	if current_state == State.DEAD:
		return

	current_health -= amount
	if is_headshot:
		GameLog.info("HEADSHOT CRITICAL! %s took %f damage (HP: %f/%f)" % [data.enemy_name, amount, current_health, data.max_health])
	else:
		GameLog.info("%s took %f damage (HP: %f/%f)" % [data.enemy_name, amount, current_health, data.max_health])

	if current_health <= 0.0:
		_die()

func _die() -> void:
	current_state = State.DEAD
	velocity = Vector3.ZERO
	enemy_died.emit(self)
	GameLog.info("%s died." % data.enemy_name)

	# Despawn delay
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)
