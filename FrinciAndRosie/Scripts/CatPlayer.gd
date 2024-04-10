extends CharacterBody2D

#player movement variables
@export var speed = 200
@export var gravity = 300
@export var jump_height = -250

var max_lives = 3
var lives = 3
var isClimbing = false

var level_start_time = Time.get_ticks_msec()

signal update_bones(treats)

func add_pickup():
	Global.treats += 1  # Update global treat count
	update_bones.emit(Global.treats)  # Emit signal for UI update
	print(Global.treats)
	
#movement and physics
func _physics_process(delta):
	if $AnimatedSprite2D.animation != "cat_death":
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
	var horizontal_input = Input.get_action_strength("cat_right") - Input.get_action_strength("cat_left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed

#animations
func player_animations():
	if $AnimatedSprite2D.animation != "cat_death":
		if isClimbing:
			$AnimatedSprite2D.play("cat_climb")
			
		if  Input.is_action_pressed("cat_jump"):
			$Jump.play()
			$AnimatedSprite2D.play("cat_jump")
			if is_on_floor():
				velocity.y = jump_height
			if Input.is_action_pressed("cat_left"):
				$AnimatedSprite2D.flip_h = false
			elif Input.is_action_pressed("cat_right"):
				$AnimatedSprite2D.flip_h = true

		#on left (add is_action_just_released so you continue running after jumping)
		if Input.is_action_pressed("cat_left") || Input.is_action_just_released("cat_jump"):
			$AnimatedSprite2D.flip_h = false
			$AttackBox.position.x = -55
			if (
				($AnimatedSprite2D.animation != "cat_attack" || ($AnimatedSprite2D.animation == "cat_attack" && !$AnimatedSprite2D.is_playing())) 
				&& ($AnimatedSprite2D.animation != "cat_jump" || is_on_floor())
				&& ($AnimatedSprite2D.animation != "cat_climb")
				):
				$AnimatedSprite2D.play("catwalk")

		#on right (add is_action_just_released so you continue running after jumping)
		if Input.is_action_pressed("cat_right") || Input.is_action_just_released("cat_jump"):
			$AnimatedSprite2D.flip_h = true
			$AttackBox.position.x = 0
			if (
				($AnimatedSprite2D.animation != "cat_attack" || ($AnimatedSprite2D.animation == "cat_attack" && !$AnimatedSprite2D.is_playing())) 
				&& ($AnimatedSprite2D.animation != "cat_jump" || is_on_floor())
				&& ($AnimatedSprite2D.animation != "cat_climb")
				):
				$AnimatedSprite2D.play("catwalk")

		#on idle if nothing is being pressed
		if !Input.is_anything_pressed() && not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("cat_idle")

	
	#on idle if nothing is being pressed
	#if !Input.is_anything_pressed():
	#	$AnimatedSprite2D.play("idle")
		
#singular input captures
func _input(event):
	if event.is_action_pressed("ui_pause"):
	#pause scene
		get_tree().paused = true
		#show menu
		$PauseMenu.visible = true
	#on attack
	if event.is_action_pressed("cat_attack"):
		$AnimatedSprite2D.play("cat_attack")
		$Meow.play()
		attack()
		#$AnimatedSprite2D.play("attack")		

	#on climbing ladders
	if Global.is_climbing:
		if Input.is_action_pressed("cat_up"):
			velocity.y = -200
		elif Input.is_action_pressed("cat_down"):
			velocity.y = 200
		
	#reset gravity
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
		if area.get_parent().is_in_group("catenemy"):
			area.get_parent().die()
			
	_on_animated_sprite_2d_animation_finished()


func _on_restart_button_pressed():
	$SelectSound.play()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed():
	$SelectSound.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_button_resume_pressed():
	$SelectSound.play()
	#unpause scene
	get_tree().paused = false
	#hide menu
	$PauseMenu.visible = false


func _on_button_save_pressed():
	$SelectSound.play()
	Global.save_game()

func _on_button_load_pressed():
	$SelectSound.play()
		# Get the current scene (Main or Main_2 in this case)
	var current_scene = get_tree().root.get_tree().current_scene
	# Free the current scene if it exists
	if current_scene:
		current_scene.queue_free()
	#load game
	Global.load_game()

func _ready():
	$AnimatedSprite2D.play("cat_idle")
	
func _on_button_quit_pressed():
	$SelectSound.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func final_score_time_and_rating():
# Time to complete in seconds
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0 # Convert to seconds
	var time_rounded = str(roundf(time_taken)) + " secs"
	print(time_rounded)
	Global.final_time = time_rounded
	
func climb(param):
	isClimbing = param
	
func take_damage():
	final_score_time_and_rating()
	$AnimatedSprite2D.play("cat_death")
	$Died.play()
	await $AnimatedSprite2D.animation_finished
	
	get_tree().paused = true
	
	#show menu
	Global.treats = 0 
	$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
	$GameOver.visible = true
	$GameOverMusic.play()

