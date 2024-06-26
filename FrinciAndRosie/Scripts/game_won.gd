extends Area2D
@export var next_level: PackedScene

var player1_on_collision = false
var player2_on_collision = false


func _ready():
	$UI/Menu.visible = false

#game over gate
func _on_body_entered(body):
	if body.name == "Player":
		player1_on_collision = true
	elif body.name == "CatPlayer":
		player2_on_collision = true
		
	if player1_on_collision && player2_on_collision: 
		body.final_score_time_and_rating()
		proceed_to_next_level()

#level end function
func proceed_to_next_level():
		set_process(false)
		$Story.show()	 
		
#restart button
func _on_restart_button_pressed():
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().reload_current_scene()

#continue button
func _on_continue_button_pressed():
	get_tree().quit()

#game won menu call
func _on_final_button_pressed():
	$Story.hide()
	$UI/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
	get_tree().paused = true
	Global.charDied = false
	$UI/Menu.visible = true
	$won.play()
	$AnimationPlayer.play("ui_visibility")
