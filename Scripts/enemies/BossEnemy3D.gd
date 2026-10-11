extends EnemyBase3D
class_name BossEnemy3D

signal boss_phase_changed(new_phase: int)
signal shield_pulse_triggered()

@export var boss_title: String = "Cybernetic Guardian Prime"
var current_phase: int = 1
var is_invulnerable: bool = false
var _phase_shield_timer: float = 0.0

func _ready() -> void:
	super._ready()
	if data == null:
		data = EnemyData.new()
		data.enemy_name = boss_title
		data.max_health = 500.0
		data.attack_damage = 30.0
	current_health = data.max_health
	add_to_group("bosses")

func take_damage(amount: float, is_headshot: bool = false) -> void:
	if is_invulnerable or current_state == State.DEAD:
		GameLog.info("%s SHIELD PROTECTED! 0 damage taken." % boss_title)
		return

	super.take_damage(amount, is_headshot)

	# Check Phase 2 transition at 50% HP
	if current_phase == 1 and current_health <= (data.max_health * 0.5):
		_transition_to_phase_two()

func _transition_to_phase_two() -> void:
	current_phase = 2
	is_invulnerable = true
	_phase_shield_timer = 3.0
	data.chase_speed *= 1.4
	data.attack_cooldown *= 0.6 # Faster attacks
	boss_phase_changed.emit(current_phase)
	shield_pulse_triggered.emit()
	GameLog.info("BOSS SHIFT! %s entered PHASE 2 (Berserk Speed + Shield Pulse)!" % boss_title)

	# Deal area-of-effect shockwave damage to nearby player
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p_node := players[0] as Node3D
		if global_position.distance_to(p_node.global_position) <= 8.0:
			if p_node.has_method("take_damage"):
				p_node.take_damage(25.0)

func _physics_process(delta: float) -> void:
	if is_invulnerable:
		_phase_shield_timer -= delta
		if _phase_shield_timer <= 0.0:
			is_invulnerable = false
			GameLog.info("%s Shield Pulse faded!" % boss_title)

	super._physics_process(delta)
