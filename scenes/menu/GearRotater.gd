extends Node2D


export var multiplier := 1.0

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	rotation += delta * multiplier
