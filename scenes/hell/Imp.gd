extends Spatial

export var speed := 1.0
export var offset := 0.0

func _ready() -> void:
	speed += randf() * 0.1
	offset = randf() * TAU

func _process(delta: float) -> void:
	$Imp.position.y = sin(Game.elapsed*speed+offset)*0.5 + 2
