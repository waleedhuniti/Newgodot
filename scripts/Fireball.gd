extends Spatial

export var speed = 15.0
export var hit_distance = 0.6
export var max_lifetime = 3.0

var damage = 14.0
var target = null
var _age = 0.0

var burst_scene = preload("res://scenes/FireballBurst.tscn")

func _physics_process(delta):
	_age += delta
	if _age > max_lifetime or target == null or not is_instance_valid(target) or target.is_dead:
		queue_free()
		return

	# Homes in on the target rather than flying a fixed straight line set at
	# spawn - the target is usually still walking (e.g. an Enemy chasing the
	# player), so a fixed heading and a moving target reliably diverge before
	# ever meeting, and the fireball just silently times out.
	look_at(target.global_transform.origin, Vector3.UP)
	translation += -transform.basis.z.normalized() * speed * delta

	if global_transform.origin.distance_to(target.global_transform.origin) <= hit_distance:
		target.take_damage(damage)
		_spawn_burst()
		queue_free()

func _spawn_burst():
	var burst = burst_scene.instance()
	get_parent().add_child(burst)
	burst.global_transform.origin = global_transform.origin
