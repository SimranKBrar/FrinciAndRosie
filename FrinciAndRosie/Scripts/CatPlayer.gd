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
	
#if cat isn't dead allow movement
func _physics_process(delta):
	if $AnimatedSprite2D.animation != "cat_death":
		velocity.y += gravity * delta
		horizontal_movement()
		move_and_slide() 
		if !Global.is_attacking:
			player_animations()
		
#horizontal function
func horizontal_movement():
	var horizontal_input = Input.get_action_strength("cat_right") - Input.get_action_strength("cat_left")
	velocity.x = horizontal_input * speed

#animation function
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

		if Input.is_action_pressed("cat_left") || Input.is_action_just_released("cat_jump"):
			$AnimatedSprite2D.flip_h = false
			$AttackBox.position.x = -55
			if (
				($AnimatedSprite2D.animation != "cat_attack" || ($AnimatedSprite2D.animation == "cat_attack" && !$AnimatedSprite2D.is_playing())) 
				&& ($AnimatedSprite2D.animation != "cat_jump" || is_on_floor())
				&& ($AnimatedSprite2D.animation != "cat_climb")
				):
				$AnimatedSprite2D.play("catwalk")

		if Input.is_action_pressed("cat_right") || Input.is_action_just_released("cat_jump"):
			$AnimatedSprite2D.flip_h = true
			$AttackBox.position.x = 0
			if (
				($AnimatedSprite2D.animation != "cat_attack" || ($AnimatedSprite2D.animation == "cat_attack" && !$AnimatedSprite2D.is_playing())) 
				&& ($AnimatedSprite2D.animation != "cat_jump" || is_on_floor())
				&& ($AnimatedSprite2D.animation != "cat_climb")
				):
				$AnimatedSprite2D.play("catwalk")

		#idle if nothing is pressed
		if !Input.is_anything_pressed() && not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("cat_idle")

#input handler
func _input(event):
	if event.is_action_pressed("ui_pause"): #pause menu
		get_tree().paused = true
		$PauseMenu.visible = true
		
	if event.is_action_pressed("cat_attack"):	#attack
		$AnimatedSprite2D.play("cat_attack")
		$Meow.play()
		attack()

	if Global.is_climbing: #climb
		if Input.is_action_pressed("cat_up"):
			velocity.y = -200
		elif Input.is_action_pressed("cat_down"):
			velocity.y = 200
	else:
		gravity = 200
		Global.is_climbing = false	
		
#wait for animations
func _on_animated_sprite_2d_animation_finished():
	Global.is_attacking = false

#attack function
func attack():
	Global.is_attacking = true
	var overlapping_objects = $AttackBox.get_overlapping_areas()
	
	for area in overlapping_objects:
		if area.get_parent().is_in_group("catenemy"):
			area.get_parent().die()
			
	_on_animated_sprite_2d_animation_finished()

#restart function
func _on_restart_button_pressed(): 
	$SelectSound.play()
	get_tree().paused = false
	get_tree().reload_current_scene()

#return to menu function
func _on_menu_button_pressed():
	$SelectSound.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

#resume button
func _on_button_resume_pressed():
	$SelectSound.play()
	get_tree().paused = false
	$PauseMenu.visible = false

#save button
func _on_button_save_pressed():
	$SelectSound.play()
	Global.save_game()
	
#load button
func _on_button_load_pressed():
	$SelectSound.play()
	var current_scene = get_tree().root.get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	Global.load_game()

#initate animations
func _ready():
	$AnimatedSprite2D.play("cat_idle")

#quit function
func _on_button_quit_pressed():
	$SelectSound.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

#get level time function
func final_score_time_and_rating():
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0 # Convert to seconds
	var time_rounded = str(roundf(time_taken)) + " secs"
	print(time_rounded)
	Global.final_time = time_rounded
	
#climb function
func climb(param):
	isClimbing = param

#kill function	
func take_damage():
	final_score_time_and_rating()
	$AnimatedSprite2D.play("cat_death")
	$Died.play()
	await $AnimatedSprite2D.animation_finished
	
	get_tree().paused = true
	Global.treats = 0 
	$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
	$GameOver.visible = true
	$GameOverMusic.play()

