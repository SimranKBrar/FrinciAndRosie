extends CharacterBody2D

#player movement variables
@export var speed = 200
@export var gravity = 300
@export var jump_height = -250
var max_lives = 1
var lives = 1
var isSwimming = false

signal update_lives(lives, max_lives)
signal update_bones(treats)
var level_start_time = Time.get_ticks_msec()

#pickup treats
func add_pickup():
	Global.treats += 1 
	update_bones.emit(Global.treats)
	print(Global.treats)

#dog movement function
func _physics_process(delta):
	if $AnimatedSprite2D.animation != "dog_death":
		velocity.y += gravity * delta
		horizontal_movement()
		move_and_slide() 
		
		if !Global.is_attacking:
			player_animations()
		
#horizontal movement
func horizontal_movement():
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = horizontal_input * speed

#animation player
func player_animations():
	if $AnimatedSprite2D.animation != "dog_death":
		if isSwimming:
			$AnimatedSprite2D.play("dog_swim")
			
		if  Input.is_action_pressed("ui_accept"):
			$Jump.play()
			$AnimatedSprite2D.play("dog_jump")
			if is_on_floor():
				velocity.y = jump_height
			if Input.is_action_pressed("ui_left"):
				$AnimatedSprite2D.flip_h = false
			elif Input.is_action_pressed("ui_right"):
				$AnimatedSprite2D.flip_h = true

		if Input.is_action_pressed("ui_left") || Input.is_action_just_released("ui_accept"):
			$AnimatedSprite2D.flip_h = true
			$AttackBox.position.x = -55
			if (
				($AnimatedSprite2D.animation != "dog_attack" || ($AnimatedSprite2D.animation == "dog_attack" && !$AnimatedSprite2D.is_playing())) 
				&& ($AnimatedSprite2D.animation != "dog_jump" || is_on_floor())
				&& ($AnimatedSprite2D.animation != "dog_swim")
				):
				$AnimatedSprite2D.play("dog_walk")

		if Input.is_action_pressed("ui_right") || Input.is_action_just_released("ui_accept"):
			$AnimatedSprite2D.flip_h = false
			$AttackBox.position.x = 0
			if (
				($AnimatedSprite2D.animation != "dog_attack" || ($AnimatedSprite2D.animation == "dog_attack" && !$AnimatedSprite2D.is_playing())) 
				&& ($AnimatedSprite2D.animation != "dog_jump" || is_on_floor())
				&& ($AnimatedSprite2D.animation != "dog_swim")
				):
				$AnimatedSprite2D.play("dog_walk")

		if !Input.is_anything_pressed() && not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("dog_idle")


#input handler
func _input(event):
	if event.is_action_pressed("ui_pause"):
		get_tree().paused = true
		$BackgroundMusic.stop()
		$PauseMenu.visible = true
		$PauseMenuMusic.play()
		
	if event.is_action_pressed("ui_attack"):
		$AnimatedSprite2D.play("dog_attack")
		$Bark.play()
		attack()	

	if Global.is_climbing:
		if Input.is_action_pressed("ui_up"):
			velocity.y = -200
		elif Input.is_action_pressed("ui_down"):
			velocity.y = 200
	else:
		gravity = 200
		Global.is_climbing = false
		
#wait for animations to stop
func _on_animated_sprite_2d_animation_finished():
	Global.is_attacking = false

#attack function
func attack():
	Global.is_attacking = true
	var overlapping_objects = $AttackBox.get_overlapping_areas()
	
	for area in overlapping_objects:
		if area.get_parent().is_in_group("dogenemy"):
			area.get_parent().die()
			
	_on_animated_sprite_2d_animation_finished()

#restart function
func _on_restart_button_pressed():
	$SelectSound.play()
	$BackgroundMusic.play()
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().reload_current_scene()

#death menu restart 
func _on_restart_button_game_over_pressed():
	$SelectSound.play()
	$BackgroundMusic.play()
	get_tree().paused = false
	get_tree().reload_current_scene()

#main menu function	
func _on_menu_button_pressed():
	$SelectSound.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

#resume button
func _on_button_resume_pressed():
	$SelectSound.play()
	$PauseMenuMusic.stop()
	$BackgroundMusic.play()
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

#quit button
func _on_button_quit_pressed():
	$SelectSound.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

#play music and start animation	
func _ready():
	$BackgroundMusic.play()
	update_bones.connect($UI/Treats.update_bones)
	$UI/Treats/Label.text = str(Global.treats)
	$AnimatedSprite2D.play("dog_idle")
	
	if Global.get_current_level_number() == 1:
		set_process(false)
		$Instructions.show()

#executed every frame
func _process(delta):
	if lives <= 0:
		emit_signal("character_died")
	if $UI/Treats/Label.text != str(Global.treats):
		$UI/Treats/Label.text = str(Global.treats)

#get level completed time		
func final_score_time_and_rating():
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0
	var time_rounded = str(roundf(time_taken)) + " secs"
	print(time_rounded)
	Global.final_time = time_rounded

#swim function
func swim(param):
	isSwimming = param

#kill pet function
func take_damage():
	final_score_time_and_rating()
	$AnimatedSprite2D.play("dog_death")
	$Died.play()
	await $AnimatedSprite2D.animation_finished
	
	get_tree().paused = true
	$UI.visible = false
	Global.treats = 0 
	
	$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
	$GameOver.visible = true
	$GameOverMusic.play()

#close instructions
func _on_accept_button_pressed():
	$SelectSound.play()
	$Instructions.hide()
	$Story.show()

#close narrrative popup
func _on_narrative_button_pressed():
	$SelectSound.play()
	$Story.hide()
	get_tree().paused = false
	set_process(true)
