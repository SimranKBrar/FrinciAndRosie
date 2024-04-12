extends Area2D
@export var next_level: PackedScene

var player1_on_collision = false
var player2_on_collision = false

# hide the menu
func _ready():
	$UI/Menu.visible = false

#checks if both characters are there
func _on_body_entered(body):
	if body.name == "Player":
		player1_on_collision = true
	elif body.name == "CatPlayer":
		player2_on_collision = true
		
	if player1_on_collision && player2_on_collision: 
		body.final_score_time_and_rating()
		proceed_to_next_level()
		
#advance to next level
func proceed_to_next_level():
	$UI/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
	get_tree().paused = true
	Global.charDied = false
	$UI/Menu.visible = true
	$FinishLevelMusic.play()
	$AnimationPlayer.play("ui_visibility")
	
#restart button
func _on_restart_button_pressed():
	$SelectSound.play()
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().reload_current_scene()
	
#continue button
func _on_continue_button_pressed():
	$SelectSound.play()
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().change_scene_to_packed(next_level)
	var path = next_level.resource_path
	var scene_name = path.get_file().split(".")[0]
	Global.current_scene_name = scene_name
