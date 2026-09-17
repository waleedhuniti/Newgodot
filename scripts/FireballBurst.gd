extends Spatial

onready var particles = $Particles

func _ready():
	var timer = get_tree().create_timer(particles.lifetime + 0.1)
	timer.connect("timeout", self, "queue_free")
