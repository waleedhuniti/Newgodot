extends CanvasLayer

onready var label = $Label

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].connect("inventory_changed", self, "_on_inventory_changed")
		_on_inventory_changed(players[0].inventory)

func _on_inventory_changed(inventory):
	label.text = "Coins: %d   Keys: %d" % [inventory.get("coin", 0), inventory.get("key", 0)]
