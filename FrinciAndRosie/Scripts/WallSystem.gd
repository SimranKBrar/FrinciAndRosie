extends Area2D

enum State {WAIT_AT_BOTTOM, MOVING_UP, WAIT_AT_TOP, MOVING_DOWN}

#move platform up
func _on_pressure_plate_area_entered(area):
	$Platform.switch_state(State.MOVING_UP)

#move platform down
func _on_pressure_plate_area_exited(area):
	$Platform.switch_state(State.MOVING_DOWN)
