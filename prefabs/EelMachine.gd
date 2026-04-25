extends MachineBase

export(Resource) var sound

func is_placeholder():
	return false

func _ready() -> void:
	$Spatial/EelSprite3D.position = Vector3(0,5,0)
	
func reposition(beat: int):
	$Spatial.position.x += -(beat % 4) + 1.5
	#$Spatial.rotation_degrees.z = -15 * (beat * 1.5 - 2)

var playing := false

func pre_beat(_beat=0):
	pass
	#get_tween()
	#tween.set_trans(Tween.TRANS_QUAD)
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property($Spatial/Spatial, "position", Vector3(0,2.2,0), GameManager.pre_beat_time_offset)

func post_beat(_beat=0):
	if eels:
		var eel = eels.pop_front()
		var tween = create_tween()
		tween.tween_property(eel, "modulate", Color.transparent, GameManager.beat_time*2)
		tween.tween_callback(eel, "queue_free")

var eels = []

func beat(_beat=0):
	if not playing:
		Game.start_sfx_stream(sound)
		playing = true
	#get_tween()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	var eel = $Spatial/EelSprite3D.duplicate()
	$Spatial.add_child(eel)
	eel.show()
	eels.append(eel)
	tween.tween_property(eel, "position", Vector3(0,2,0), 0.1)
	tween.tween_callback(self, "post_beat").set_delay(0.2)
	
	
func end_beat():
	if playing:
		Game.stop_sfx_stream(sound)
		playing = false
