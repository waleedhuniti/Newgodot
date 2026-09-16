extends Area

export(Resource) var item_type
export var amount = 1
export var spin_speed = 1.5

func _ready():
	add_to_group("pickups")
	connect("body_entered", self, "_on_body_entered")

func _process(delta):
	rotate_y(spin_speed * delta)

func _on_body_entered(body):
	if item_type and body.has_method("add_item"):
		body.add_item(item_type, amount)
		queue_free()
