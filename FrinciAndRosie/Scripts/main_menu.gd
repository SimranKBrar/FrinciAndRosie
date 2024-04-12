extends CanvasLayer


#Play background music
func _ready():
	$BackgroundMusic.play()

#load button
func _on_button_load_pressed():
	$SelectSound.play()
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	Global.load_game()
	get_tree().paused = false  

#quit button
func _on_button_quit_pressed():
	$SelectSound.play()
	get_tree().quit()

#new level pressed
func _on_button_new_pressed():
	$SelectSound.play()
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	var new_scene = load("res://Scenes/Main.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().set_current_scene(new_scene)
	Global.current_scene_name = new_scene.name
	get_tree().paused = false
