extends ColorRect

@onready var label = $Label

func update_bones(treats):
	label.text = str(treats)
