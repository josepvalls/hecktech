extends MachineBase


func pre_beat(_beat=0):
	move()
	
func post_beat(_beat=0):
	pass


func beat(_beat=0):
	pass
	
var scroll_offset = Vector2.ZERO

var m: ShaderMaterial

func _ready() -> void:
	m = $TopMeshInstance.mesh.surface_get_material(0).duplicate()
	$TopMeshInstance.material_override = m
	#call_deferred("post_ready")
	
func post_ready():
	pass
	#m = m.duplicate()
	
	#$TopMeshInstance.mesh.surface_set_material(0, m)


var skip_beats = 1

func move():
	if skip_beats:
		skip_beats -= 1
		return
	var t = create_tween()
	t.set_parallel(true)
	for i in [
		$Gear1, $Gear2, $Gear3, $Gear4, $Gear5
	]:
		t.tween_property(i, "rotation", Vector3(0,0,-PI), GameManager.pre_beat_time_offset).as_relative()
	for i in [
		$GearB1, $GearB2, $GearB3, $GearB4
	]:
		t.tween_property(i, "rotation", Vector3(0,0,PI), GameManager.pre_beat_time_offset).as_relative()
	
	t.tween_method(self, "_update_shader", scroll_offset, scroll_offset + Vector2(-1,0.0) * GameManager.pre_beat_time_offset, GameManager.pre_beat_time_offset)
	#t.chain()
	#t.tween_callback(m, "set_shader_param", ["scroll_speed", Vector2.ZERO])
	#scroll_offset += Vector2(0.5,0.0) * GameManager.pre_beat_time_offset
	#t.tween_callback(m, "set_shader_param", ["scroll_offset", scroll_offset])
	
# This function is called every frame by the tween
func _update_shader(val):
	#prints("scroll_offset", val)
	scroll_offset = val
	m.set_shader_param("scroll_offset", val)
