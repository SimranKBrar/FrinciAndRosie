extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_load_pressed():
	pass # Replace with function body.


func _on_button_quit_pressed():
	get_tree().quit()


func _on_button_new_pressed():
	# Get the current scene
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
