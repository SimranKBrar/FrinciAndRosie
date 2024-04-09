extends Area2D


func _on_body_entered(body):
	print("Player entered the door area.")
	if body.name == "CatPlayer":
		Global.is_climbing = true

#sets is_climbing to false to simulate climbing
func _on_body_exited(body):
	if body.name == "CatPlayer":
		Global.is_climbing = false
		

