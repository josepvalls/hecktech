extends Spatial


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animate()

func animate():
	var t = create_tween()
	t.tween_callback($Tracks/Conveyor2, "pre_beat")
	t.tween_interval(0.5)
	t.tween_callback($Tracks/Conveyor1, "pre_beat")
	#t.tween_callback($Conveyor, "pre_beat")
	t.tween_interval(0.5)
	t.tween_callback(self, "animate")
