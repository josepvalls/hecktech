class_name MachineBase
extends Spatial

var tween: SceneTreeTween
var default_material: SpatialMaterial

func is_placeholder():
	return true

var kind = 0
var size = 1
var beat = 0
var cost = 0
var default_color := Color.yellow

func get_tween():
	if tween:
		tween.kill()
	tween = create_tween()

func _ready() -> void:
	if get_node_or_null("MeshInstance"):
		default_material = $MeshInstance.mesh.surface_get_material(0).duplicate()
		$MeshInstance.material_override = default_material
		post_beat()

func reposition(beat: int):
	default_color = Color.yellow.linear_interpolate(Color.orange, (beat % 4) / 3.0) 
	default_material.albedo_color = default_color
	

func pre_beat(_beat=0):
	default_material.albedo_color = Color.green
	
func post_beat(_beat=0):
	default_material.albedo_color = default_color

func beat(_beat=0):
	get_tween()
	default_material.albedo_color = Color.red
	tween.tween_property(default_material, "albedo_color", default_color, GameManager.beat_time)
	
	
onready var player := get_node_or_null("AudioStreamPlayer") as AudioStreamPlayer

func end_beat():
	pass
