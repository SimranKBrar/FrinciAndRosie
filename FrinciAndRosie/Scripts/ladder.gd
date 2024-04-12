extends Area2D

#cat climbing
func _on_body_entered(body):
	print("Player entered the door area.")
	if body.name == "CatPlayer":
		body.climb(true)
		Global.is_climbing = true

#cat not climbing
func _on_body_exited(body):
	if body.name == "CatPlayer":
		body.climb(false)
		Global.is_climbing = false
		

