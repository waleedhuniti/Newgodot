extends "res://scripts/AnimatedCharacter.gd"

export var walk_speed = 3.5
export var run_speed = 7.0
export var gravity = -20.0
export var jump_speed = 7.0
export var rotation_speed = 12.0
export var mouse_sensitivity = 0.0035

export var attack_range = 2.2
export var attack_damage = 6.0
export var attack_cooldown = 1.2
export var skill_range = 2.6
export var skill_damage = 14.0
export var skill_cooldown = 4.0

var velocity = Vector3.ZERO
var camera_pivot_yaw = 0.0
var camera_pivot_pitch = -0.35

onready var camera_pivot = $CameraPivot
onready var camera = $CameraPivot/Camera

var target = null
var _attack_timer = 0.0
var _skill_timer = 0.0
var _busy_until = 0.0

var inventory = {}
signal inventory_changed(inventory)

func _ready():
	max_health = 100.0
	health = max_health
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	play_anim("Idle")

func add_item(item_id, item_amount = 1):
	inventory[item_id] = inventory.get(item_id, 0) + item_amount
	emit_signal("inventory_changed", inventory)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_pivot_yaw -= event.relative.x * mouse_sensitivity
		camera_pivot_pitch = clamp(camera_pivot_pitch - event.relative.y * mouse_sensitivity, -1.2, 0.3)
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		var mode = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		_try_select_target()
	if event is InputEventKey and event.pressed and event.scancode == KEY_1:
		_try_use_skill()

func _try_select_target():
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 100
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	if result and result.collider and result.collider.is_in_group("enemies"):
		target = result.collider

func _clear_dead_target():
	if target != null and (not is_instance_valid(target) or target.is_dead):
		target = null

func _try_use_skill():
	if is_dead or target == null or target.is_dead:
		return
	if _skill_timer > 0.0 or _time_now() < _busy_until:
		return
	var dist = global_transform.origin.distance_to(target.global_transform.origin)
	if dist > skill_range:
		return
	_face_target()
	play_anim("2H_Melee_Attack_Spin", true)
	_busy_until = _time_now() + 0.6
	_skill_timer = skill_cooldown
	target.take_damage(skill_damage)

func _time_now():
	return OS.get_ticks_msec() / 1000.0

func _face_target():
	if target == null:
		return
	var to_target = target.global_transform.origin - global_transform.origin
	if to_target.length() > 0.01:
		model.rotation.y = atan2(to_target.x, to_target.z)

func _physics_process(delta):
	_clear_dead_target()
	if _attack_timer > 0.0:
		_attack_timer -= delta
	if _skill_timer > 0.0:
		_skill_timer -= delta

	camera_pivot.rotation.y = camera_pivot_yaw
	camera_pivot.rotation.x = camera_pivot_pitch

	var input_dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1

	var moving = input_dir.length() > 0.01
	if moving:
		input_dir = input_dir.normalized()

	# movement is relative to the camera's yaw, not the world axes
	var yaw_basis = Basis(Vector3.UP, camera_pivot_yaw)
	var move_dir = yaw_basis.xform(input_dir)

	var speed = run_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

	if is_on_floor():
		velocity.y = 0
		if Input.is_key_pressed(KEY_SPACE):
			velocity.y = jump_speed
	else:
		velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector3.UP)

	var busy = _time_now() < _busy_until
	if is_dead:
		pass
	elif busy:
		pass
	elif moving:
		var target_angle = atan2(move_dir.x, move_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)
		play_anim("Running_A" if speed == run_speed else "Walking_A")
	elif target != null and not target.is_dead:
		var dist = global_transform.origin.distance_to(target.global_transform.origin)
		if dist <= attack_range and _attack_timer <= 0.0:
			_face_target()
			play_anim("1H_Melee_Attack_Slice_Horizontal", true)
			_busy_until = _time_now() + 0.5
			_attack_timer = attack_cooldown
			target.take_damage(attack_damage)
		else:
			play_anim("Idle")
	else:
		play_anim("Idle")

func die():
	.die()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
