extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export (String, FILE) var sound
func activate():
	if sound:
		Game.play_sfx(sound)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Hammer, "rotation_degrees", -85, 0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Hammer, "rotation_degrees", 0, 2.0).set_delay(0.2)
