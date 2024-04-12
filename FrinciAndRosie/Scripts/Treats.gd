extends ColorRect

@onready var label = $Label

#update number of bones
func update_bones(treats):
	label.text = str(treats)
