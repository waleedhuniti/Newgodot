extends KinematicBody

export var walk_speed = 3.5
export var run_speed = 7.0
export var gravity = -20.0
export var jump_speed = 7.0
export var rotation_speed = 12.0
export var mouse_sensitivity = 0.0035

var velocity = Vector3.ZERO
var camera_pivot_yaw = 0.0
var camera_pivot_pitch = -0.35

onready var camera_pivot = $CameraPivot
onready var camera = $CameraPivot/Camera
onready var model = $Model
onready var anim_player = _find_animation_player(model)

var current_anim = ""

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_play_anim("Idle")

func _find_animation_player(node):
	if node == null:
		return null
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found = _find_animation_player(child)
		if found:
			return found
	return null

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_pivot_yaw -= event.relative.x * mouse_sensitivity
		camera_pivot_pitch = clamp(camera_pivot_pitch - event.relative.y * mouse_sensitivity, -1.2, 0.3)
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		var mode = Input.get_mouse_mode()
		if mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
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

	if moving:
		var target_angle = atan2(move_dir.x, move_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)
		_play_anim("Running_A" if speed == run_speed else "Walking_A")
	else:
		_play_anim("Idle")

func _play_anim(anim_name):
	if anim_player == null or current_anim == anim_name:
		return
	if anim_player.has_animation(anim_name):
		anim_player.play(anim_name)
		current_anim = anim_name
