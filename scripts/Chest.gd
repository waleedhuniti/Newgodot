extends Area

export(Resource) var required_item_type
export(Resource) var reward_item_type
export var reward_amount = 1
export var open_angle = -100.0

var _player_in_range = null
var _opened = false

onready var lid = $Model/chest_gold/chest_gold_lid

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.has_method("add_item"):
		_player_in_range = body

func _on_body_exited(body):
	if body == _player_in_range:
		_player_in_range = null

func _unhandled_input(event):
	if _opened or _player_in_range == null:
		return
	if event is InputEventKey and event.pressed and event.scancode == KEY_E:
		_try_open()

func _try_open():
	var inv = _player_in_range.inventory
	var consumed = inv.consume_items({required_item_type: 1})
	if consumed.size() == 0:
		return
	_opened = true
	_player_in_range.add_item(reward_item_type, reward_amount)
	lid.rotation_degrees.x = open_angle
