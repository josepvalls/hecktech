extends Sprite3D

onready var speed = 1.0 + randf()

func _process(delta: float) -> void:
	position.x = sin(speed * Game.elapsed) * 0.3
	position.y = sin(speed * Game.elapsed*2) * 0.15
