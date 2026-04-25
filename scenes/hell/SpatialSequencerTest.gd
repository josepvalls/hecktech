extends Spatial


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_conveyors()


func set_conveyors():
	var ref = $Spirit
	ref.position.x -= 15
	var t := create_tween()
	t.set_parallel(true)
	t.tween_callback($Hammer, "activate")
	for i in 15:
		var r = ref.duplicate()
		add_child(r)
		r.position.x += (i+1)*2
		t.tween_property(r, "position", r.position+Vector3(2,0,0), 4.0).from(r.position)
	t.chain()
	t.set_loops(0)
		
