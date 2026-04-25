extends MachineBase

func _ready() -> void:
	$Spatial/Soul.hide()
	$Spatial.position = Vector3(-6,2,0)

func pre_beat(_beat=0):
	pass
	
func post_beat(_beat=0):
	pass


func beat(_beat=0):
	get_tween()
	# rest to open and down
	tween.set_parallel(true)
	tween.tween_property($Spatial/LeftSprite3D, "rotation_degrees", Vector3(0,0,-15), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial/RightSprite3D, "rotation_degrees", Vector3(0,0,15), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial, "position", Vector3(-6,-2,0), GameManager.beat_time * 0.5)
	tween.chain()
	tween.tween_interval(GameManager.beat_time * 0.5)
	tween.chain()
	# open to closed and up
	tween.tween_property($Spatial/LeftSprite3D, "rotation_degrees", Vector3(0,0,30), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial/RightSprite3D, "rotation_degrees", Vector3(0,0,-30), GameManager.beat_time * 0.5)
	tween.chain()
	tween.tween_callback($Spatial/Soul, "show")
	tween.tween_interval(GameManager.beat_time * 0.5)
	tween.chain()	
	# move up
	tween.tween_property($Spatial, "position", Vector3(-6,2,0), GameManager.beat_time * 0.5)
	tween.chain()	
	# move left
	tween.tween_property($Spatial, "position", Vector3(0,2,0), GameManager.beat_time * 0.5)
	tween.chain()	
	# closed to open
	tween.tween_property($Spatial/LeftSprite3D, "rotation_degrees", Vector3(0,0,-15), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial/RightSprite3D, "rotation_degrees", Vector3(0,0,15), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial/Soul, "position",Vector3(0,-2,0), GameManager.beat_time * 0.5)
	tween.chain()
	tween.tween_callback($Spatial/Soul, "hide")
	tween.chain()
	tween.tween_property($Spatial/Soul, "position",Vector3(0,0,0), GameManager.beat_time * 0.5)
	# closed to rest
	tween.tween_property($Spatial/LeftSprite3D, "rotation_degrees", Vector3(0,0,0), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial/RightSprite3D, "rotation_degrees", Vector3(0,0,0), GameManager.beat_time * 0.5)
	tween.tween_property($Spatial, "position", Vector3(-6,2,0), GameManager.beat_time * 0.5)
	
	
