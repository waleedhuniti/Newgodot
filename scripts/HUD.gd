extends CanvasLayer

onready var label = $Label

var coin_type = preload("res://resources/item_types/ItemType_Coin.tres")
var key_type = preload("res://resources/item_types/ItemType_Key.tres")
var player_inventory = null

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_inventory = players[0].inventory
		player_inventory.connect("item_stack_added", self, "_on_inventory_changed")
		player_inventory.connect("item_stack_changed", self, "_on_inventory_changed")
		player_inventory.connect("item_stack_removed", self, "_on_inventory_changed")
		_on_inventory_changed()

func _on_inventory_changed(_a = null, _b = null):
	var counts = player_inventory.count_all_items()
	label.text = "Coins: %d   Keys: %d" % [counts.get(coin_type, 0), counts.get(key_type, 0)]
