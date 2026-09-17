extends CanvasLayer

# Projects a 3D point above the target's head to screen space every frame,
# the same technique as DamageNumber.gd - Godot 3.x has no billboard/3D UI
# node for this. Parented directly under the Enemy, so it's freed
# automatically along with it.

export var height_offset = 2.2
export var width = 60.0

var target = null

onready var bar = $Bar

func set_target(t):
	target = t

func set_health(current, max_hp):
	bar.max_value = max_hp
	bar.value = current

func _process(_delta):
	if target == null or not is_instance_valid(target):
		queue_free()
		return
	var camera = get_viewport().get_camera()
	if camera == null:
		return
	var pos3d = target.global_transform.origin + Vector3(0, height_offset, 0)
	if camera.is_position_behind(pos3d):
		bar.visible = false
		return
	bar.visible = true
	var screen_pos = camera.unproject_position(pos3d)
	bar.rect_position = screen_pos - Vector2(width / 2.0, 0)
