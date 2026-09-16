extends "res://scripts/AnimatedCharacter.gd"

export var move_speed = 2.2
export var aggro_range = 8.0
export var attack_range = 2.0
export var attack_damage = 5.0
export var attack_cooldown = 1.5
export var gravity = -20.0
export var despawn_delay = 4.0

var velocity = Vector3.ZERO
var _attack_timer = 0.0
var _busy_until = 0.0
var _player = null

func _ready():
	add_to_group("enemies")
	play_anim("Idle")

func _time_now():
	return OS.get_ticks_msec() / 1000.0

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector3.UP)
		return

	if _attack_timer > 0.0:
		_attack_timer -= delta

	if _player == null or not is_instance_valid(_player):
		_player = _find_player()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if _player == null or _player.is_dead:
		velocity.x = 0
		velocity.z = 0
		velocity = move_and_slide(velocity, Vector3.UP)
		play_anim("Idle")
		return

	var to_player = _player.global_transform.origin - global_transform.origin
	var dist = to_player.length()
	var busy = _time_now() < _busy_until

	if dist > aggro_range:
		velocity.x = 0
		velocity.z = 0
		play_anim("Idle")
	elif dist > attack_range:
		var dir = to_player.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		if not busy:
			model.rotation.y = atan2(dir.x, dir.z)
			play_anim("Walking_A")
	else:
		velocity.x = 0
		velocity.z = 0
		if not busy:
			model.rotation.y = atan2(to_player.x, to_player.z)
			if _attack_timer <= 0.0:
				play_anim("Unarmed_Melee_Attack_Punch_A", true)
				_busy_until = _time_now() + 0.5
				_attack_timer = attack_cooldown
				_player.take_damage(attack_damage)
			else:
				play_anim("Idle")

	velocity = move_and_slide(velocity, Vector3.UP)

func die():
	.die()
	set_collision_layer(0)
	set_collision_mask(0)
	var timer = get_tree().create_timer(despawn_delay)
	timer.connect("timeout", self, "queue_free")
