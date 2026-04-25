extends MachineBase

export(Resource) var sound

export var rotate_machine := true

func is_placeholder():
	return false

func _ready() -> void:
	$Spatial/Particles.emitting = false
	#post_beat()
	
func reposition(beat: int):
	$Spatial.position.x += -(beat % 4) + 1.5
	#$Spatial.position.x += -(beat % 4) + 1.5
	#if rotate_machine:
	#	$Spatial.rotation_degrees.z = -15 * (beat * 1.5 - 2)


func beat(_beat=0):
	Game.start_sfx_stream(sound)
	#get_tween()
	#tween.tween_callback($Spatial/Particles, "set_emitting", [true])
	$Spatial/Particles.set_emitting(true)
	
	
func end_beat():
	Game.stop_sfx_stream(sound)
	$Spatial/Particles.set_emitting(false)
	#tween.tween_interval(GameManager.beat_time * 0.5)
	#tween.tween_callback($Spatial/Particles, "set_emitting", [false])
