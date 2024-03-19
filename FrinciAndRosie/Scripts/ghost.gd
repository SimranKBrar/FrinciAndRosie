extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("idle")



func _on_body_entered(body):
	if body.name == "Player":
		$AnimatedSprite2D.play("dis")
		$Timer.start()


func _on_timer_timeout():
	if is_instance_valid(self):
		self.queue_free()
