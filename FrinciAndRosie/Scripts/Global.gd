extends Node

var is_attacking = false
var is_climbing = false

	#current scene
var current_scene_name

func _ready():
	# Sets the current scene's name
	current_scene_name = get_tree().get_current_scene().name
