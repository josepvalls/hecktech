extends MachineBase

export(Resource) var sound
export(Resource) var sound2

export var rotate_machine := true

func is_placeholder():
	return false

func _ready() -> void:
	$Spatial/Particles.emitting = false
	#post_beat()
	
func reposition(beat: int):
	$Spatial.position.x += -(beat % 4) + 1.5
	$Spatial.position.z += (beat % 4) * -0.1
	if rotate_machine:
		$Spatial.rotation_degrees.z = -10 * (beat * 1.5 - 2)
	if beat >= 2:
		#$Spatial/Head.scale.y = -1
		$Spatial/Head.scale.x = -1
		$Spatial/Head.rotation_degrees.z += 45 + 90


func pre_beat(_beat=0):
	pass
	
func post_beat(_beat=0):
	pass


func beat(_beat=0):
	if _beat % 4 == 0:
		Game.play_sfx(sound)
	else:
		Game.play_sfx(sound2)

	get_tween()
	tween.tween_callback($Spatial/Particles, "set_emitting", [true])
	tween.set_parallel(true)
	tween.tween_property($Spatial/Head/Top, "rotation_degrees", Vector3(0,0,35), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial/Head/Bottom, "rotation_degrees", Vector3(0,0,-35), GameManager.beat_time * 0.5)
	#tween.tween_interval(GameManager.beat_time * 0.5)
	tween.chain()
	tween.tween_callback($Spatial/Particles, "set_emitting", [false])
	tween.tween_property($Spatial/Head/Top, "rotation_degrees", Vector3(0,0,0), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial/Head/Bottom, "rotation_degrees", Vector3(0,0,0), GameManager.beat_time * 0.5)
	
	
