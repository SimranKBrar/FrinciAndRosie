extends CharacterBody2D

#player movement variables
@export var speed = 300
@export var gravity = 300
@export var jump_height = -55

signal update_lives(lives, max_lives)

	# health stats
var max_lives = 1
var lives = 1

signal update_bones(treats)
var level_start_time = Time.get_ticks_msec()
func add_pickup():
	Global.treats += 1  # Update global treat count
	update_bones.emit(Global.treats)  # Emit signal for UI update
	print(Global.treats)
#movement and physics
func _physics_process(delta):
	# vertical movement velocity (down)
	velocity.y += gravity * delta
	# horizontal movement processing (left, right)
	horizontal_movement()
	
	#applies movement
	move_and_slide() 
	
	#applies animations
	if !Global.is_attacking:
		player_animations()
		
#horizontal movement calculation
func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed

#animations
func player_animations():
	#on left (add is_action_just_released so you continue running after jumping)
	if Input.is_action_pressed("ui_left") || Input.is_action_just_released("ui_accept"):
		$AnimatedSprite2D.flip_h = true
		$AttackBox.position.x = -55
		$AnimatedSprite2D.play("dog_walk")
		
	#on right (add is_action_just_released so you continue running after jumping)
	if Input.is_action_pressed("ui_right") || Input.is_action_just_released("ui_accept"):
		$AnimatedSprite2D.flip_h = false
		$AttackBox.position.x = 0
		$AnimatedSprite2D.play("dog_walk")

	#on jump
	if  Input.is_action_pressed("ui_accept") and is_on_floor():
		$AnimatedSprite2D.play("dog_jump")
		velocity.y = jump_height
		
			#on idle if nothing is being pressed
	if !Input.is_anything_pressed():
		$AnimatedSprite2D.play("dog_idle")
#singular input captures
func _input(event):
	if event.is_action_pressed("ui_pause"):
	#pause scene
		get_tree().paused = true
		#show menu
		$BackgroundMusic.stop()
		$PauseMenu.visible = true
		
		$PauseMenuMusic.play()
	#on attack
	if event.is_action_pressed("ui_attack"):
		attack()
		$AnimatedSprite2D.play("dog_attack")		

	if Global.is_climbing:
		if Input.is_action_pressed("ui_up"):
			velocity.y = -200
		elif Input.is_action_pressed("ui_down"):
			velocity.y = 200
	else:
		gravity = 200
		Global.is_climbing = false
		
#reset our animation variables
func _on_animated_sprite_2d_animation_finished():
	Global.is_attacking = false
#	is_climbing = false	


func attack():

	Global.is_attacking = true
	var overlapping_objects = $AttackBox.get_overlapping_areas()
	
	for area in overlapping_objects:
		if area.get_parent().is_in_group("dogenemy"):
			area.get_parent().die()
			
	_on_animated_sprite_2d_animation_finished()


func _on_restart_button_pressed():
	$BackgroundMusic.play()
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().reload_current_scene()

func _on_restart_button_game_over_pressed():
	$BackgroundMusic.play()
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_button_resume_pressed():
	#unpause scene
	$PauseMenuMusic.stop()
	$BackgroundMusic.play()
	get_tree().paused = false
	#hide menu
	$PauseMenu.visible = false


func _on_button_save_pressed():
	Global.save_game()


func _on_button_load_pressed():
	# Get the current scene (Main or Main_2 in this case)
	var current_scene = get_tree().root.get_tree().current_scene
	# Free the current scene if it exists
	if current_scene:
		current_scene.queue_free()
	#load game
	Global.load_game()


func _on_button_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _ready():
	

	$BackgroundMusic.play()
	#updates our UI labels when signals are emitted
	update_bones.connect($UI/Treats.update_bones)

	#show our correct lives value on load
	$UI/Treats/Label.text = str(Global.treats)
	
func _process(delta):
	if lives <= 0:
		emit_signal("character_died")
	# Check for changes in the global variable and update UI label if needed
	if $UI/Treats/Label.text != str(Global.treats):
		$UI/Treats/Label.text = str(Global.treats)
		
func final_score_time_and_rating():
# Time to complete in seconds
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0 # Convert to seconds
	var time_rounded = str(roundf(time_taken)) + " secs"
	print(time_rounded)
	Global.final_time = time_rounded
	
func take_damage():
	print("takedamge")
	$AnimatedSprite2D.play("dog_death")
	get_tree().paused = true
	#show menu
	Global.treats = 0 
	$GameOver.visible = true

