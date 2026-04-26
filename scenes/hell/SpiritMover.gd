extends MachineBase

export var start_with_visible_soul := false

func reset():
	$Soul.visible = start_with_visible_soul
	skip_beats = 1

var bar = 0
var skip_beats = 1
export var track := 0
var food_destination: Spatial

func pre_beat(_beat=0):
	if track == 0:
		Game.play_sfx(preload("res://assets/sfx/One_Shots/SHARP_PS_Kit01_Clap_One_Shot.wav"))

	move()

func beat(_beat=0):
	pass
	
func move():
	$Soul.show()
	
	if skip_beats:
		skip_beats -= 1
		return

	if bar < 3:
		var t = create_tween()
		t.tween_property(self, "position", Vector3(4,0,0), GameManager.pre_beat_time_offset).as_relative()
		bar += 1
	else:
		bar = 0
		GameManager.score_soul(self)
		position.x = -8
		
	
func torture(coords: Vector2, kind: int):
	if coords.y == track:
		match kind:
			1:
				$Soul.play("stab")
			2:
				$Soul.play("burn")
			3:
				$Soul.play("eel")
			4:
				$Soul.play("eel")
			5:
				$Soul.play("smash")
			6:
				$Soul.play("smash")
			7:
				$Soul.play("stab")
			_:
				pass
