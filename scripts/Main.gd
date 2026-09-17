extends Spatial

# Dev/test helper: run with `--screenshot=/path/out.png [--frames=N] [--auto-quit]
# [--debug-cam] [--verbose]` to capture a frame for automated verification without
# a human watching (see docs/TECHNICAL_PLAN.md §3 for the full headless workflow).
# NOTE: the flag is --auto-quit, not --quit - Godot's own engine already reserves
# "--quit" to mean "close after the first frame", which silently ate this before
# it got that name (screenshot never got taken, no error, clean exit - very
# confusing to debug).
# --debug-cam switches to the top-down DebugCamera instead of the player's own
# camera, useful for checking a whole scene layout at once.
# --test-combat auto-targets the nearest enemy for the player (skipping the
# mouse click) and logs health every 30 frames, since a single screenshot
# can't show a fight playing out over time.
# --test-pickup teleports the player onto each standalone pickup in turn
# (skipping walking there) and logs inventory contents after each, since
# pickup is a physics overlap that a screenshot alone can't confirm worked.
var _screenshot_path = ""
var _screenshot_frame = 20
var _frame = 0
var _test_combat = false
var _test_pickup = false
var _test_fireball = false
var _test_chest = false
var _pickup_queue = []
var _chest_key_type = preload("res://resources/item_types/ItemType_Key.tres")

func _ready():
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr(len("--screenshot="))
		elif arg.begins_with("--frames="):
			_screenshot_frame = int(arg.substr(len("--frames=")))
	_test_combat = "--test-combat" in OS.get_cmdline_args()
	_test_pickup = "--test-pickup" in OS.get_cmdline_args()
	_test_fireball = "--test-fireball" in OS.get_cmdline_args()
	_test_chest = "--test-chest" in OS.get_cmdline_args()
	if _screenshot_path != "" and "--debug-cam" in OS.get_cmdline_args():
		$DebugCamera.current = true
	if _test_combat:
		call_deferred("_setup_test_combat")
	if _test_pickup:
		call_deferred("_setup_test_pickup")
	if _test_fireball:
		call_deferred("_setup_test_fireball")
	if "--test-inventory-panel" in OS.get_cmdline_args():
		call_deferred("_setup_test_inventory_panel")

func _setup_test_inventory_panel():
	var player = get_node_or_null("Player")
	var hud = get_node_or_null("HUD")
	if player and hud:
		player.add_item(preload("res://resources/item_types/ItemType_Coin.tres"), 3)
		player.add_item(_chest_key_type, 1)
		hud.inventory_panel.visible = true
		print("TEST-INVENTORY-PANEL: opened with items")

func _setup_test_fireball():
	# Deliberately doesn't pre-set player.target - this exercises the
	# auto-acquire-nearest-enemy fallback in _try_use_skill(), which is
	# exactly what a real player relies on when they press 1 without having
	# clicked an enemy first.
	var player = get_node_or_null("Player")
	var enemies = get_tree().get_nodes_in_group("enemies")
	if player and enemies.size() > 0:
		player._try_use_skill()
		print("TEST-FIREBALL: cast at ", enemies[0].name)

func _setup_test_combat():
	var player = get_node_or_null("Player")
	var enemies = get_tree().get_nodes_in_group("enemies")
	if player and enemies.size() > 0:
		player.target = enemies[0]
		print("TEST-COMBAT: player targeting ", enemies[0].name)

func _setup_test_pickup():
	_pickup_queue = get_tree().get_nodes_in_group("pickups").duplicate()

func _log_combat_status():
	var player = get_node_or_null("Player")
	var enemies = get_tree().get_nodes_in_group("enemies")
	var player_hp = player.health if player else -1
	var enemy_status = []
	for e in enemies:
		enemy_status.append("%s hp=%s dead=%s" % [e.name, e.health, e.is_dead])
	var pickups = get_tree().get_nodes_in_group("pickups").size()
	print("TEST-COMBAT frame=%d player_hp=%s enemies=%s pickups_in_world=%d" % [_frame, player_hp, enemy_status, pickups])

func _run_test_pickup_step():
	var player = get_node_or_null("Player")
	if player == null:
		return
	if _pickup_queue.size() > 0:
		var next = _pickup_queue.pop_front()
		if is_instance_valid(next):
			player.transform.origin = next.global_transform.origin
			print("TEST-PICKUP: moved player to ", next.name)
	else:
		var counts = player.inventory.count_all_items()
		var readable = {}
		for item_type in counts:
			readable[item_type.name] = counts[item_type]
		print("TEST-PICKUP: final inventory = ", readable)

func _run_test_chest_step():
	var player = get_node_or_null("Player")
	var chest = get_node_or_null("Chest")
	if player == null or chest == null:
		return
	if _frame == 15:
		player.add_item(_chest_key_type, 1)
		player.transform.origin = chest.global_transform.origin + Vector3(2, 0, 0)
		print("TEST-CHEST: moved player to chest with 1 key")
	elif _frame == 30:
		chest._try_open()
		print("TEST-CHEST: tried to open")
	elif _frame == 45:
		var counts = player.inventory.count_all_items()
		var readable = {}
		for item_type in counts:
			readable[item_type.name] = counts[item_type]
		print("TEST-CHEST: final inventory = ", readable)

func _debug_dump():
	var player = get_node_or_null("Player")
	if player:
		print("DEBUG Player transform: ", player.transform)
		print("DEBUG camera global transform: ", player.camera.global_transform)
		print("DEBUG anim_player: ", player.anim_player, " animations: ", (player.anim_player.get_animation_list() if player.anim_player else []))

func _process(_delta):
	if _test_combat or _test_fireball:
		_frame += 1
		if _frame % 15 == 0:
			_log_combat_status()
	elif _test_pickup:
		_frame += 1
		if _frame % 15 == 0:
			_run_test_pickup_step()
	elif _test_chest:
		_frame += 1
		_run_test_chest_step()

	if _screenshot_path == "":
		return
	if not _test_combat and not _test_pickup and not _test_fireball and not _test_chest:
		_frame += 1
	if _frame == _screenshot_frame:
		if "--verbose" in OS.get_cmdline_args():
			_debug_dump()
		var img = get_viewport().get_texture().get_data()
		img.flip_y()
		img.save_png(_screenshot_path)
		print("SCREENSHOT SAVED: ", _screenshot_path)
		if "--auto-quit" in OS.get_cmdline_args():
			get_tree().quit()
