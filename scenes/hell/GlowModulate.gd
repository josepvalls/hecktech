extends Sprite3D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animate()



func animate():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(randf()*0.125+1.125, 1, 1, 1), randf() * 0.2).set_delay(randf() * 0.2)
	tween.tween_callback(self, "animate")
