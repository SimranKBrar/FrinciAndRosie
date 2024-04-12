extends Area2D

#if cat enters kill, if dog enters swim
func _on_area_2d_area_entered(area):
	if area.get_parent().name == "CatPlayer":
		area.get_parent().take_damage()
	if area.get_parent().name == "Player":
		area.get_parent().swim(true)

#reset on exit
func _on_area_2d_area_exited(area):
	if area.get_parent().name == "Player":
		area.get_parent().swim(false)
