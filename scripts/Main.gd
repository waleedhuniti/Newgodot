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
var _screenshot_path = ""
var _screenshot_frame = 20
var _frame = 0

func _ready():
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr(len("--screenshot="))
		elif arg.begins_with("--frames="):
			_screenshot_frame = int(arg.substr(len("--frames=")))
	if _screenshot_path != "" and "--debug-cam" in OS.get_cmdline_args():
		$DebugCamera.current = true

func _debug_dump():
	var player = get_node_or_null("Player")
	if player:
		print("DEBUG Player transform: ", player.transform)
		print("DEBUG camera global transform: ", player.camera.global_transform)
		print("DEBUG anim_player: ", player.anim_player, " animations: ", (player.anim_player.get_animation_list() if player.anim_player else []))

func _process(_delta):
	if _screenshot_path == "":
		return
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
