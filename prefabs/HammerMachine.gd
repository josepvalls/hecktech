extends MachineBase

export(Resource) var sound
export(Resource) var sound2

func is_placeholder():
	return false

func _ready() -> void:
	$Spatial/Spatial.rotation_degrees = Vector3.ZERO
	
func reposition(beat: int):
	pass
	#$Spatial.position.x += -(beat % 4) + 1.5
	#$Spatial.rotation_degrees.y = -15 * (beat * 1.5 - 2)


func pre_beat(_beat=0):
	get_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Spatial/Spatial, "rotation_degrees", Vector3(0,0,-10), GameManager.pre_beat_time_offset)

	
func post_beat(_beat=0):
	get_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Spatial/Spatial, "rotation_degrees", Vector3(0,0,0), GameManager.beat_time*2)



func beat(_beat=0):
	if _beat % 4 == 0:
		Game.play_sfx(sound)
	else:
		Game.play_sfx(sound2)
	get_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Spatial/Spatial, "rotation_degrees", Vector3(0,0,60), GameManager.pre_beat_time_offset)
	tween.tween_callback(self, "post_beat").set_delay(0.2)
	
	
