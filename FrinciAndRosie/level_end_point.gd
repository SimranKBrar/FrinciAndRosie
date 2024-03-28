extends Area2D
@export var next_level: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/Menu.visible = false


func _on_body_entered(body):
	if body.name == "Player":
		get_tree().paused = true
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
