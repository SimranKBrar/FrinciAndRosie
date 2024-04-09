extends Node
var final_score
var final_rating
var final_time

var is_attacking = false
var is_climbing = false
var is_jumping = false
	#current scene
var current_scene_name



	# health stats
var treats = 1
var charDied = false

const SAVE_PATH = "user://savegame.save"
func save_game():
	var save_file = ConfigFile.new()
	# Save the current level
	save_file.set_value("level", "current_level", "res://Scenes/" + Global.current_scene_name + ".tscn")
	# Save the file
	var err = save_file.save(SAVE_PATH)
		# Err handling
	if err != OK:
		print("An error occurred while saving the game")
	else:
		print("Saving game.")
	
	
func get_current_level_number():
	if current_scene_name == "Main" || current_scene_name == "MainMenu":
		return 1
	elif current_scene_name.begins_with("Main_"):
	# Extract the number after "Main_"
		var level_number = current_scene_name.get_slice("_", 1).to_int()
		return level_number
	else:
		return -1 # Indicate an unknown scene
			
			
func load_game():
	var save_file = ConfigFile.new()
	var err = save_file.load(SAVE_PATH)

	# Check if the save file exists and is successfully loaded
	if err == OK:
		# Get the full path to the current level from the save file
		var saved_level = save_file.get_value("level", "current_level", "res://Scenes/Main.tscn")
		# Load and instantiate the saved scene
		var new_scene_resource = load(saved_level)
		var new_scene = new_scene_resource.instantiate()
		# Add it to the root of the scene tree
		get_tree().get_root().add_child(new_scene)
		# Set it as the current scene
		get_tree().current_scene = new_scene
		#update current scene name
		current_scene_name = get_tree().get_current_scene().name
		clean_scene_name(current_scene_name)
		#notify
		print("Loading game.")
	else:
		print("An error occurred while loading the game")
		var current_scene = get_tree().current_scene
		# Free the current scene if it exists
		if current_scene:
			current_scene.queue_free()
		var new_scene = load("res://Scenes/Main.tscn").instantiate()
		get_tree().root.add_child(new_scene)
		# Set the new scene as the current scene
		get_tree().set_current_scene(new_scene)
		# Update the global variable with the name of the new scene
		Global.current_scene_name = new_scene.name
		# Ensures scene isn't paused
		get_tree().paused = false
	
func clean_scene_name(scene_name):
	var at_position = scene_name.find("@")
	if at_position != -1:
		# Extract the portion of the string before the "@" character
		return scene_name.substr(0, at_position)
	else:
		# If "@" character is not fsound, return the original string
		return scene_name
	


func _ready():
	# Sets the current scene's name
	var scene_name = get_tree().get_current_scene().name
	current_scene_name = clean_scene_name(scene_name)
