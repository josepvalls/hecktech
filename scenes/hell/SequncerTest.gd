extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_sequencer()


var slots = []
var bpm = 140
var op = []
func setup_sequencer():
	#$AudioStreamPlayer.connect("finished", self, "round2")
	$MachineClaw/AnimationPlayer.advance(1.5)
	var o = $MachineStart.rect_position - Vector2(0,50)
	var n = 8
	var w = 100
	for i in n:
		#var r = ColorRect.new()
		#r.rect_size = Vector2(w,w)
		#r.rect_position = Vector2(i*w, 0) + o
		if i % 4 == 0:
			var r = $Hammer.duplicate()
			r.position  = Vector2(i*w, 0) + o
			add_child(r)
			slots.append(r)
		else:
			var r = $MiniHammer.duplicate()
			r.position  = Vector2(i*w, 0) + o
			add_child(r)
			slots.append(r)
	op = $Line2D.points
	$Line2D.hide()
	$Line2D2.hide()
			
func toggle2():
	if $Line2D.visible:
		$MachineStart.modulate = Color.white
		$Line2D2.hide()
		$Line2D.hide()
		$AudioStreamPlayer2.stop()
	else:		
		$AudioStreamPlayer2.play($AudioStreamPlayer.get_playback_position() - current_beat * (60.0 / bpm))
		$MachineStart.modulate = Color.blue
		$Line2D2.show()
		$Line2D.show()

func _process(delta: float) -> void:
	process_beat()
	if $Line2D.visible:
		var p = $Line2D.points
		for i in len(p):
			p[i] = op[i]+Vector2(-15,-15) +Vector2(30*randf(),30*randf())
		$Line2D.points = p
		$Line2D2.points = p
	
onready var player := $AudioStreamPlayer
var current_beat = -1
func process_beat():
	var offset = player.get_playback_position()
	var current_beat_ = int(offset / (60.0 / bpm))
	#prints(offset, current_beat_)
	if current_beat_ > current_beat:
		current_beat = current_beat_
		set_beat()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		toggle2()

const p0 = Vector2(585,409)
#var g_pos = -1
var gtween: SceneTreeTween
func set_beat():
	if gtween:
		gtween.kill()
	gtween = create_tween()
	
	if current_beat >=0:
		var beat = current_beat % 8
		if current_beat == 0:
			$Ghost.position = p0
		gtween.tween_property($Ghost, "position", p0 + Vector2((beat+1) * 100,0), (60.0 / bpm)).from(p0 + Vector2(beat * 100,0))#.set_delay(0.3)
		#for i in slots:
		#	i.color = Color.white
		#slots[current_beat % len(slots)].color = Color.black
		#if beat % 2 == 0:
		slots[beat].activate()
		if current_beat == 16:
			#round2()
			pass
	
