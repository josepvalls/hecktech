extends Node2D
class_name RaccoonAnimation

var points = []
var random_delay := 0.0
export var animation_time = 0.2
export var animation_kind = 0
export var animation_speed = 1.0
export var attack_kind := 0
var origin: Vector2
var tail_origin = Vector2.ZERO
func _ready():
	origin = position
	points = $Racoon.polygon
	if get_node_or_null("Tail"):
		tail_origin = $Tail.position
	random_delay = randf() * TAU


func _process(_delta):
	match animation_kind:
		-1:
			position.y = origin.y -pow(sin(Game.elapsed*animation_speed + random_delay),2) * 25
			var points_ = Array(points)
			var offset = Vector2(0.0, sin(GameManager.elapsed * animation_speed + random_delay) * 10)
			points_[1] += offset * 0.75
			points_[2] += offset * 0.25
			points_[-3] += offset * 0.25
			points_[-2] += offset * 0.75
			$Racoon.polygon = points_
			if tail_origin:
				$Tail.position = tail_origin + offset

		0:
			var points_ = Array(points)
			var offset = Vector2.RIGHT.rotated(GameManager.elapsed * animation_speed + random_delay) * 25
			points_[0] += offset
			points_[-1] += offset
			points_[-2] += offset * 0.5
			$Racoon.polygon = points_
			if tail_origin:
				$Tail.rotation = sin(GameManager.elapsed * 2.0 + random_delay) * 0.1

		1:
			var points_ = Array(points)
			var offset = Vector2(sin(GameManager.elapsed * 2.0 + random_delay) * 15, 0.0)
			points_[1] += offset * 0.75
			points_[-2] += offset
			$Racoon.polygon = points_
			if tail_origin:
				$Tail.rotation = sin(GameManager.elapsed * 4.0 + random_delay) * 0.1
				$Tail.position = tail_origin + offset
		2:
			var points_ = Array(points)
			var offset = Vector2(0.0, sin(GameManager.elapsed * 3.0 + random_delay) * 10)
			points_[0] += offset * 0.5
			points_[1] += offset
			points_[-2] += offset
			points_[-1] += offset * 0.5
			$Racoon.polygon = points_
			if tail_origin:
				$Tail.rotation = pow(sin(GameManager.elapsed * 4.0 + random_delay),2) * 0.2
				$Tail.position = tail_origin + offset
		3:
			var points_ = Array(points)
			var offset = Vector2(0.0, sin(GameManager.elapsed * animation_speed + random_delay) * 10)
			points_[0] += offset * 0.5
			points_[1] += offset
			points_[-2] += offset
			points_[-1] += offset * 0.5
			$Racoon.polygon = points_


func reset():
	$RacoonAttack1.modulate = Color(1,1,1,0)
	$RacoonAttack2.modulate = Color(1,1,1,0)
	$Racoon.modulate = Color(1,1,1,1)

func attack():
	match attack_kind:
		0:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property($Racoon, "modulate", Color(1,1,1,0), animation_time).from(Color(1,1,1,1))
			tween.tween_property($RacoonAttack1, "modulate", Color(1,1,1,1), animation_time).from(Color(1,1,1,0))
			
			tween.chain()
			tween.tween_property($RacoonAttack1, "modulate", Color(1,1,1,0), animation_time).from(Color(1,1,1,1))
			tween.tween_property($RacoonAttack2, "modulate", Color(1,1,1,1), animation_time).from(Color(1,1,1,0))
			tween.chain()
			tween.tween_property($RacoonAttack2, "modulate", Color(1,1,1,0), animation_time).from(Color(1,1,1,1))
			tween.tween_property($Racoon, "modulate", Color(1,1,1,1), animation_time).from(Color(1,1,1,0))
		1:
			$Particles2D.emitting = true
	
