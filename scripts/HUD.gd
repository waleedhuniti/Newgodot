extends CanvasLayer

onready var label = $InventoryPanel/Label
onready var inventory_panel = $InventoryPanel
onready var tutorial = $Tutorial
onready var health_bar = $HealthBar
onready var mana_bar = $ManaBar

var player_inventory = null

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		player_inventory = player.inventory
		player_inventory.connect("item_stack_added", self, "_on_inventory_changed")
		player_inventory.connect("item_stack_changed", self, "_on_inventory_changed")
		player_inventory.connect("item_stack_removed", self, "_on_inventory_changed")
		_on_inventory_changed()

		player.connect("health_changed", self, "_on_health_changed")
		_on_health_changed(player.health, player.max_health)

		player.connect("mana_changed", self, "_on_mana_changed")
		_on_mana_changed(player.mana, player.max_mana)

func _on_inventory_changed(_a = null, _b = null):
	var counts = player_inventory.count_all_items()
	if counts.size() == 0:
		label.text = "Inventory: empty"
		return
	var text = "Inventory: "
	for item_type in counts:
		text += "%s x%d   " % [item_type.name, counts[item_type]]
	label.text = text

func _on_health_changed(current, max_hp):
	health_bar.max_value = max_hp
	health_bar.value = current

func _on_mana_changed(current, mana_max):
	mana_bar.max_value = mana_max
	mana_bar.value = current

func _process(_delta):
	# The mouse isn't captured until the player's first click (browsers block
	# a page from grabbing the pointer without a real user gesture), so this
	# prompt stays up until that happens, telling the player why nothing
	# seems to respond yet and what the controls are once it does.
	tutorial.visible = Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_I:
		inventory_panel.visible = not inventory_panel.visible
