tool
class_name Polygon2DArmatureAnimator
extends Polygon2D


var _elapsed = 0.0
export var speed = 1.0
var _points = []

export (Array, float) var animated_points_multipliers = [
	0.25,1.0,0.25,0.0,0.0,0.0,0.0,0.0
]
export var point_offset_multiplier = Vector2(0, 10.0)

func _ready():
	_points = polygon
	


func _process(delta):
	if not _points or not visible:
		return
	_elapsed += delta * speed
	var points = Array(_points)
	for idx in len(animated_points_multipliers):
		points[idx] += Vector2(cos(_elapsed), sin(_elapsed)) * point_offset_multiplier * animated_points_multipliers[idx]
	polygon = points
