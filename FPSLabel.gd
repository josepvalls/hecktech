class_name FPSLabel
extends Label


func _ready():
	pass # Replace with function body.


func _process(_delta):
	text = str(Engine.get_frames_per_second())
