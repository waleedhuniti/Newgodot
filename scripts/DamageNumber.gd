extends CanvasLayer

# A floating "-N" that rises and fades over its own damage source's position.
# Godot 3.x has no Label3D/billboard text, so this projects a 3D world point
# to screen space each frame via the active camera instead.

export var lifetime = 0.8
export var rise_speed = 1.2

var world_position = Vector3.ZERO
var age = 0.0

onready var label = $Label

func set_amount(amount):
	label.text = str(int(round(amount)))

func _process(delta):
	age += delta
	if age >= lifetime:
		queue_free()
		return
	var camera = get_viewport().get_camera()
	if camera == null:
		return
	var pos3d = world_position + Vector3(0, rise_speed * age, 0)
	var screen_pos = camera.unproject_position(pos3d)
	label.rect_position = screen_pos - label.rect_size * 0.5
	label.modulate.a = 1.0 - (age / lifetime)
