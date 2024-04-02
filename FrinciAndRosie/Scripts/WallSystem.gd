extends Area2D

enum State {WAIT_AT_BOTTOM, MOVING_UP, WAIT_AT_TOP, MOVING_DOWN}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_pressure_plate_area_entered(area):
	$Platform.switch_state(State.MOVING_UP)


func _on_pressure_plate_area_exited(area):
	$Platform.switch_state(State.MOVING_DOWN)
