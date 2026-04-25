extends Spatial


var souls = []

func _ready() -> void:
	initial_souls()
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(self, "spawn_soul")
	tween.set_loops(0)
	
func initial_souls():
	for i in 12:
		spawn_soul(i*3)

func spawn_soul(z_offset = 0.0):
	var s = $Soul.duplicate()
	s.position.z += z_offset
	s.set_meta("elapsed", Game.elapsed)
	s.set_meta("speed", randf() * 2)
	add_child(s)
	souls.append(s)
	s.position.x = randf()-0.5
	
func _process(delta: float) -> void:
	for s in souls:
		s.position.y += delta * 0.5
		s.position.y = min(s.position.y, 0.5)
		s.position.z += delta * 1.5
		s.position.x = 0.25 + sin((1.0+s.get_meta("speed", 0.0))*Game.elapsed-s.get_meta("elapsed", 0.0)) * 0.10
		if s.position.z > 32.0:
			s.queue_free()
			souls.erase(s)
