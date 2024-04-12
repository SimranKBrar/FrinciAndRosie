extends Area2D

#pickup treat
func _on_body_entered(body):
	if body.name == "Player" || body.name == "CatPlayer":
		get_tree().queue_delete(self)
		body.add_pickup()
