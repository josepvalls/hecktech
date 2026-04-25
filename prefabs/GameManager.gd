extends Node

var start_default_currency = 666
var current_currency = 4

var bpm = 140
var beat_time = 0.0
var pre_beat_time_offset = 0.2

var player: AudioStreamPlayer

var track_num := 4
var track_length := 16

var track_machines = []
var track_slots = {}
var other_slots = []

var playing = false

var tracks_bought = 0

signal player_on_stream_finished
signal update_ui_needed
signal new_score(value, source)

func reset():
	player.stop()
	# make sure any playing machine is stopped
	for i in track_machines:
		pre_delete_machine(i)
	track_machines = []
	track_slots = {}
	other_slots = []
	playing = false
	tracks_bought = 0
	current_currency = start_default_currency
	

func _ready():
	beat_time = (60.0 / bpm)
	pre_beat_time_offset = beat_time * 0.5
	player = AudioStreamPlayer.new()
	add_child(player)
	player.connect("finished",self, "player_on_stream_finished")
	player.bus = "Music"
	
func play(track: String, reset_tracks=true):
	current_pre_beat = -1
	current_beat = -1
	if reset_tracks:
		current_tracks_active = 0
	player.stream = load(track)
	player.play()
	playing = true
	
func player_on_stream_finished():
	playing = false
	emit_signal("player_on_stream_finished")

func _process(_delta: float) -> void:
	process_beat()


var current_pre_beat = -1
var current_beat = -1
var current_tracks_active = 0

var score_count := [0,0,0,0]
func score_soul(track: Spatial):
	score_count[track.track]+=1
	prints("score_soul score_count", score_count)
	
	var food = preload("res://prefabs/Food.tscn").instance()
	var m = GameManager.get_machines_in_track(track.track)
	Game.play_sfx(preload("res://assets/sfx/FL_CT_Kit3_140BPM_D#min/FL_CT_Kit3_140BPM_One_Shots/r0.wav"))
	var score = 0

	if len(m) < 4:
		score += 0
	elif len(m) < 8:
		score += 0.25
	elif len(m) < 16:
		score += 0.50
	elif len(m) < 24:
		score += 0.75
	else:
		score += 1.0
		
	if len(m) in [1,2,4,8,16,32]:
		score += 1.0
		
	var consec = get_consecutive_machines_in_track(track.track)
	if consec < 4:
		score += 1.0
	elif consec < 8:
		score += 0.5
	elif consec < 16:
		score += 0.25

	var counts = machine_kind_count(m)		
	if len(counts) < 2:
		score += 0.25
	elif len(counts) < 3:	
		score += 0.50
	elif len(counts) < 4:	
		score += 0.75
	else:
		score += 1.0
		
		
	
	current_currency += int(score * 20)
	add_child(food)

	if len(m) == 0:
		food.set_rank("E")
	elif score < 1:
		food.set_rank("D")
	elif score < 2:
		food.set_rank("D")
	elif score < 3:
		food.set_rank("C")
	elif score < 3.6:
		food.set_rank("B")
	else:
		food.set_rank("A")

	food.global_position = track.get_node("Soul").global_position
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(food, "global_position", track.food_destination.global_position + Vector3(track.track/4.0-0.5,5.0+score/2.0,-track.track/8.0), GameManager.beat_time*2).set_delay(GameManager.beat_time)
	t.tween_interval(GameManager.beat_time * track.track)
	if true or track.track ==0:
		if score < 3:
			t.tween_callback(Game, "play_sfx", [yucks.pick_random()])
		else:
			t.tween_callback(Game, "play_sfx", [yums.pick_random()])
	t.tween_property(food, "global_position", track.food_destination.global_position + Vector3(0,-2.0,0), GameManager.beat_time)
	t.tween_callback(food, "queue_free")
	
	
	
	emit_signal("new_score", score*10, food)
	emit_signal("update_ui_needed")

const yums = [
	preload("res://assets/sfx/Yum/1.ogg"),
	preload("res://assets/sfx/Yum/1b.ogg"),
	preload("res://assets/sfx/Yum/1c.ogg"),
	preload("res://assets/sfx/Yum/1d.ogg"),
	preload("res://assets/sfx/Yum/2.ogg"),
	preload("res://assets/sfx/Yum/2c.ogg")
]
const yucks = [
	preload("res://assets/sfx/Ew/1.ogg"),
	preload("res://assets/sfx/Ew/2.ogg"),
	preload("res://assets/sfx/Ew/3.ogg"),
	preload("res://assets/sfx/Ew/4.ogg"),
	preload("res://assets/sfx/Ew/7.ogg"),
]

func process_beat():
	if not playing:
		return
	var offset = player.get_playback_position()
	
	
	var current_pre_beat_ = int((offset+pre_beat_time_offset) / beat_time)
	if current_pre_beat_ > current_pre_beat:
		if current_pre_beat_ % track_length == 0:
			if current_tracks_active < tracks_bought:
				current_tracks_active += 1
		
		current_pre_beat = current_pre_beat_
		pre_beat()

	
	var current_beat_ = int(offset / beat_time)
	if current_beat_ > current_beat:
		current_beat = current_beat_
		beat()

var playing_queue = []
func beat():
	var beat_mod = current_beat % track_length
	
	if beat_mod == 0 and current_beat > 0:
		for i in playing_queue:
			i[0].end_beat()
		playing_queue = []
		
	for i in track_slots.keys():
		if i.y < current_tracks_active and i.x == beat_mod:
			track_slots[i].beat(beat_mod)
			if not track_slots[i].is_placeholder():
				playing_queue.append([track_slots[i], track_slots[i].size])
	for i in other_slots:
		if i[0].y < current_tracks_active and i[0].x == beat_mod:
			i[1].beat(beat_mod)

	var playing_queue_ = []
	for i in playing_queue:
		i[1]-=1
		if i[1]<=0:
			i[0].end_beat()
		else:
			playing_queue_.append(i)
	playing_queue = playing_queue_
			
func pre_delete_machine(m):
	if not playing_queue:
		return
	var playing_queue_ = []
	for i in playing_queue:
		if i[0] == m:
			i[0].end_beat()
		else:
			playing_queue_.append(i)
	playing_queue = playing_queue_
				
		
	
func pre_beat():
	var beat_mod = current_pre_beat % track_length
	for i in track_slots.keys():
		if i.y < current_tracks_active and i.x == beat_mod:
			track_slots[i].pre_beat(beat_mod)
			
	for i in other_slots:
		if i[0].y < current_tracks_active and i[0].x == beat_mod:
			i[1].pre_beat(beat_mod)


func get_machines_in_track(track: int):
	var machines = []
	for i in track_slots.keys():
		if i.y == track and not track_slots[i].is_placeholder():
			machines.append(track_slots[i])
	#prints("get_machines_in_track", track, len(machines))
	return machines


func get_consecutive_machines_in_track(track: int):
	var current_kind = -1
	var largest = 0
	var current = 0
	for x in track_length:
		var kind = 0
		var coords = Vector2(x,track)
		if coords in track_slots:
			kind = track_slots[coords].kind
		if kind == current_kind:
			current += 1
			if current > largest:
				largest = current
		else:
			current = 1
	return largest
	
func machine_kind_count(m):
	var counts = {}
	for i in m:
		counts[i.kind] = counts.get(i.kind, 0) + 1
	return counts
