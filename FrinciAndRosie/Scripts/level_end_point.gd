extends Area2D
@export var next_level: PackedScene

var player1_on_collision = false
var player2_on_collision = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/Menu.visible = false
	$Death/Menu.visible = false
	

func _on_body_entered(body):
	if body.name == "Player":
		player1_on_collision = true
	elif body.name == "CatPlayer":
		player2_on_collision = true
		
	if player1_on_collision && player2_on_collision: 
		body.final_score_time_and_rating()
		proceed_to_next_level()

func proceed_to_next_level():
	$UI/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
	get_tree().paused = true
	Global.charDied = false
	$UI/Menu.visible = true
	# animation to make menu's modular value visible
	$AnimationPlayer.play("ui_visibility")
	

func _on_restart_button_pressed():
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().reload_current_scene()


func _on_continue_button_pressed():
	get_tree().paused = false
	$UI/Menu.visible = false
	get_tree().change_scene_to_packed(next_level)
	# Extract the name of the packed scene file and update the current scene's name in the Global script
	var path = next_level.resource_path
	var scene_name = path.get_file().split(".")[0]
	Global.current_scene_name = scene_name

