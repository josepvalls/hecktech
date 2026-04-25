extends Spatial


func _ready() -> void:
	pass
	
var rank: String
func set_rank(rank_):
	rank = rank_
	$AnimatedSprite3D.animation = rank
	$AnimatedSprite3D.play(rank)
	$Particles.emitting = true
	$Particles2.emitting = true
