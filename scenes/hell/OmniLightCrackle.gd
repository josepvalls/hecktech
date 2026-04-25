extends OmniLight

export var original_energy := 1.0
export var variance := 0.5

func _ready() -> void:
	animate()


func animate():
	var tween = create_tween()
	tween.tween_property(self, "light_energy", original_energy * (1.0 + randf()*variance-variance*0.5), randf() * 0.3 + 0.1)#.set_delay(randf() * 0.3 + 0.1)
	tween.tween_callback(self, "animate")
