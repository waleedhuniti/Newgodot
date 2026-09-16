extends KinematicBody
# Shared base for any KayKit-style character (player, enemies, later NPCs):
# finding the AnimationPlayer buried inside the imported model, playing named
# animations without restarting an already-playing one, and basic health.
#
# Reused instead of duplicated because every character sharing the model
# format needs the same animation lookup - not a hypothetical future need.

export var max_health = 30.0
export var death_anim = "Death_A"

var health = max_health
var is_dead = false
var current_anim = ""

onready var model = $Model
onready var anim_player = _find_animation_player(model)

signal died(character)
signal health_changed(current, max_hp)

func _find_animation_player(node):
	if node == null:
		return null
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found = _find_animation_player(child)
		if found:
			return found
	return null

func play_anim(anim_name, restart_ok = false):
	if anim_player == null:
		return
	if current_anim == anim_name and not restart_ok:
		return
	if anim_player.has_animation(anim_name):
		anim_player.play(anim_name)
		current_anim = anim_name

func take_damage(amount):
	if is_dead:
		return
	health = max(0.0, health - amount)
	emit_signal("health_changed", health, max_health)
	if health <= 0:
		die()
	else:
		play_anim("Hit_A", true)

func die():
	if is_dead:
		return
	is_dead = true
	play_anim(death_anim, true)
	emit_signal("died", self)
