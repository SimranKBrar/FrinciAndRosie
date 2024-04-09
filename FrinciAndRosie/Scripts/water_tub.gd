extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	print(area.get_parent().name)
	if area.get_parent().name == "CatPlayer":
		area.get_parent().queue_free()
	if area.get_parent().name == "Player":
		area.get_parent().swim(true)

func _on_area_2d_area_entered(area):
	if area.get_parent().name == "CatPlayer":
		Global.charDied = true
		area.get_parent().queue_free()
	if area.get_parent().name == "Player":
		area.get_parent().swim(true)

func _on_area_2d_area_exited(area):
	if area.get_parent().name == "Player":
		area.get_parent().swim(false)
