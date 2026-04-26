extends CanvasLayer

var in_dialog := true

var dialog_data = []
var current_line = -1
func _ready() -> void:
	$"%DialogAudioStreamPlayer".connect("finished", self, "audio_finished")
	for i in lines():
		dialog_data.append(i.split("\t"))

var tween: SceneTreeTween

func audio_finished():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_callback(self, "next_line").set_delay(0.5)

func end_dialog():
	current_line = 0
	in_dialog = false
	$"%SceneFrame".queue_free()
	$"%DialogAudioStreamPlayer".queue_free()
	hide()

func next_line():
	if tween:
		tween.kill()
	
	if current_line < len(dialog_data)-1:
		current_line += 1
	else:
		end_dialog()
		
	
	var line_data = dialog_data[current_line]
	
	$"%DialogName".text = line_data[0]
	$"%DialogText".text = line_data[1]
	$"%SceneFrame".texture = load("res://assets/hell/CUTSCENE/"+line_data[2]+".png")
	$"%DialogAudioStreamPlayer".stream = load("res://assets/sfx/" + line_data[4])
	$"%DialogAudioStreamPlayer".play()


func _process(delta: float) -> void:
	if in_dialog:
		if Input.is_action_just_pressed("do_a"):
			next_line()
		

func lines():
	return """Satan	IIIIIIIIMPS!!!	1		Devil Open/1.ogg
Baldrick & Boris	Yes, sir?	3		Imps/1.ogg
Satan	THESE SOULS ARE RAW!!!	5		Devil Open/2.ogg
Satan	Do you expect me to consume these unabused, untormented, unpunished souls!?	7		Devil Open/3.ogg
Satan	Look at this one. It still has its original hope intact. It's practically organic!	9		Devil Open/4.ogg
Satan	This is it, you useless slaves. You are all fired!!!	11		Devil Open/5.ogg
Baldrick	But sir! We've been tormenting like this for millennia. It's hand-crafted suffering!	13		Imps/2.ogg
Boris	We provide artisan, small-batch damnation!	13		Imps/4.ogg
Satan	I am surrounded by idiots...	15		Devil Open/6.ogg
Satan	Artisan is just a marketing term for "inefficient" you useless skin-sacks.	15		Devil Open/7.ogg
Satan	It's not the dark ages any more. The humans are years ahead of us in terms of automation.	17		Devil Open/8.ogg
Satan	They've already replaced their artists with prompt-monkeys and their thinkers with chat bots.	23		Devil Open/9.ogg
Satan	And what're we using? Pitchforks? Hellfire? How retro. How... pathetic.	25		Devil Open/10.ogg
Satan	It's time to get onboard with the current times.	27		Devil Open/11.ogg
Satan	I will build the ultimate torturing machine.	29		Devil Open/12.ogg
Satan	IIIIMPS, GET TO WORK!	31		Devil Open/13c.ogg
Baldrick & Boris	Yes, sir!	33		Imps/5.ogg""".split("\n")
