extends Spatial

export var is_active := true
export var can_build := false
export var debug_make_machines := false
export var debug_unlock_tracks := false
export var skip_dialog := false

var current_size = 1
var current_kind = 1
var is_building := false
var is_deleting := false

const build_sounds = [
	preload("res://assets/sfx/Imps/5b.ogg"),
	preload("res://assets/sfx/Imp Positive/1.ogg"),
	preload("res://assets/sfx/Imp Positive/2.ogg"),
	preload("res://assets/sfx/Imp Positive/3.ogg"),
	preload("res://assets/sfx/Imp Positive/4.ogg"),
]
const delete_sounds = [
	preload("res://assets/sfx/Imp Negative/1.ogg"),
	preload("res://assets/sfx/Imp Negative/2.ogg"),
	preload("res://assets/sfx/Imp Negative/4.ogg"),
	preload("res://assets/sfx/Imp Negative/5.ogg"),
	preload("res://assets/sfx/Imp Negative/6.ogg"),
]

var kind_to_name = {
	KIND.STAB: "Stab",
	KIND.BURN: "Burn",
	KIND.EEL: "Eel",
	KIND.FART: "Fart",
	KIND.HAMMER: "Punch",
	KIND.FROST: "Frost",
	KIND.SAW: "Saw",
}

var kind_to_base_cost = {
	KIND.STAB: 20,
	KIND.BURN: 30,
	KIND.EEL: 25,
	KIND.FART: 50,
	KIND.HAMMER: 60,
	KIND.FROST: 60,
	KIND.SAW: 15,
}

var kind_to_size = {
	KIND.STAB: [1,2],
	KIND.BURN: [1,2],
	KIND.EEL: [4],
	KIND.FART: [4],
	KIND.HAMMER: [1,2],
	KIND.FROST: [2,4],	
	KIND.SAW: [1,2],	
}
var size_to_label = {
	1: "x1",
	2: "x2",
	4: "x4",
	8: "XL",
	16: "XXL",
	32: "XXXL",
}

class BuildButton:
	var kind:= 0
	var size:= 0
	var cost:=0 
	var ui: Button

var buttons = []

func make_buttons():
	$"%BuiltButton".hide()
	for kind in kind_to_base_cost:
		for size in kind_to_size[kind]:
			var b = BuildButton.new()
			b.kind = kind
			b.size = size
			b.cost = kind_to_base_cost[kind] * size
			b.ui = $"%BuiltButton".duplicate()
			b.ui.text = kind_to_name[kind] + "\n" + size_to_label[size] + " ("+str(b.cost)+")"
			$"%BuiltButton".get_parent().add_child(b.ui)
			b.ui.hide()
			b.ui.connect("pressed", self, "select_size", [kind+1,size])
			buttons.append(b)
			

func _ready() -> void:
	$DialogCanvasLayer.show()
	GameManager.reset()
	if debug_make_machines:
		GameManager.tracks_bought = 4
	make_buttons()
	make_tracks()
	if debug_make_machines:
		#make_machines()
		make_machines2()
		#make_machines3()
		#make_machines4()
	$"%CancelBuildButton".connect("pressed", self, "select_size", [0,1])
	$"%UnlockTrackButton".connect("pressed", self, "unlock_track")
	$"%EraseBuildButton".connect("pressed", self, "start_delete")
	$"%PlayStopButton".connect("pressed", self, "do_play_stop")
	$"%MenuButton".connect("pressed", self, "do_reset")
	$"%SkipButton".connect("pressed", $DialogCanvasLayer, "end_dialog")
	
	$"%PlayStopButton".disabled = true
	$"%UnlockTrackButton".disabled = true
	$"%EraseBuildButton".disabled = true
	GameManager.connect("player_on_stream_finished", self, "playback_finished")
	for i in GameManager.track_num:
		get_node("Tracks/SoulMover" + str(i+1)).food_destination = $"%BigPlate"
	GameManager.connect("update_ui_needed", self, "update_ui")
	GameManager.connect("new_score", self, "new_score")
	update_ui()

func do_reset():
	playback_finished()
	reset_tracks()
	GameManager.reset()
	Game.restart_scene()

func playback_finished():
	$"%PlayStopButton".disabled = false
	update_ui()

func new_score(value: int, source: Spatial):
	var world_position = source.global_position # Or any Vector3(x, y, z)
	var camera = get_viewport().get_camera()
	var screen_position = camera.unproject_position(world_position)
	var label = $"%CurrencyLabel".duplicate()
	label.rect_global_position = screen_position - label.rect_size * 0.5
	label.text =  "+" + str(value)
	$CanvasLayer.add_child(label)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, "modulate", Color.transparent, GameManager.beat_time)
	tween.tween_callback(label, "queue_free")
	

func reset_tracks():
	GameManager.reset()
	update_ui()

func can_play_machine():
	return len(GameManager.track_machines)>0 and not GameManager.playing
	
func can_buy_tracks():
	return GameManager.tracks_bought < GameManager.track_num and GameManager.current_currency > track_cost and GameManager.tracks_bought * 4 <= len(GameManager.track_machines)

func can_build():
	return GameManager.tracks_bought > 0

func update_ui():
	$"%PlayStopButton".disabled = not can_play_machine()
	$"%EraseBuildButton".disabled = not can_play_machine()
	$"%UnlockTrackButton".disabled = not can_buy_tracks()
	$"%EraseBuildButton".disabled = not can_play_machine()	
	$"%CurrencyLabel".text = str(GameManager.current_currency)
	if can_build():
		for i in buttons:
			i.ui.visible = GameManager.current_currency >= i.cost
			
	

func pre_start(params):
	select_size(0,0)
	var cur_scene: Node = get_tree().current_scene
	print("Current scene is: ", cur_scene.name, " (", cur_scene.filename, ")")

func start():
	print("Start")
	if skip_dialog:
		$DialogCanvasLayer.end_dialog()
	else:
		$DialogCanvasLayer.show()
		$DialogCanvasLayer.next_line()
	#var t = create_tween()
	#t.tween_callback(GameManager, "play", ["res://assets/bgm/Kit01_140_Full_Mix_D#.wav"]).set_delay(0.5)
	#t.tween_callback(GameManager, "play", ["res://assets/sfx/Stems/SHARP_PS_Kit01_140_Bass_Stem_D#.wav"]).set_delay(0.5)
	#t.tween_callback(GameManager, "play", ["res://assets/sfx/Stems/SHARP_PS_Kit01_140_Vocal_Stem_Chop_D#.wav"]).set_delay(0.5)
	#GameManager.play("res://assets/bgm/Kit01_140_Full_Mix_D#.wav")

func do_play_stop():
	if debug_unlock_tracks:
		GameManager.current_tracks_active = 4
		GameManager.play("res://assets/sfx/Stems/SHARP_PS_Kit01_140_Vocal_Stem_Chop_D#.wav", false)
	else:
		GameManager.play("res://assets/sfx/Stems/SHARP_PS_Kit01_140_Vocal_Stem_Chop_D#.wav")
	$Tracks/SoulMover1/Soul.show()
	for i in [$Tracks/SoulMover1, $Tracks/SoulMover2, $Tracks/SoulMover3, $Tracks/SoulMover4]:
		i.reset()
	$"%PlayStopButton".disabled = true
	

var current_track_coords = Vector2.ZERO
func select_size(kind: int, size:int):
	var mesh := selection_placeholder.get_node("Mesh") as MeshInstance
	if kind > 0:
		$"%CancelBuildButton".show()
		$"%CancelBuildButton".text = "Cancel\nSelected: " + kind_to_name[kind-1] + " (" + str(kind_to_base_cost[kind-1]*size) + ")"
		$"%BuildVBoxContainer".hide()
		current_kind = kind
		current_size = size
		selection_placeholder.show()
		mesh.mesh.size.x = size - 0.2
		mesh.position.x = size / 2.0 - 0.5
		is_building = true
		selection_placeholder.show()
		track_placeholders.show()
	else:
		$"%CancelBuildButton".hide()
		$"%BuildVBoxContainer".show()
		selection_placeholder.hide()
		track_placeholders.hide()
		selection_placeholder.hide()
		is_building = false
		is_deleting = false
		
func start_delete():
	$"%CancelBuildButton".show()
	$"%CancelBuildButton".text = "Cancel\nRemove station"
	$"%BuildVBoxContainer".hide()
	selection_placeholder.show()
	track_placeholders.show()
	is_deleting = true
	is_building = false
	

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseButton and event.button_index==BUTTON_LEFT and event.pressed:
		if is_building and can_build:
			build_structure()
		elif is_deleting and can_build:
			delete_structure()
	elif event is InputEventMouseButton and event.button_index==BUTTON_RIGHT and event.pressed:
		select_size(0,0)
	elif event is InputEventMouseMotion:
		move_cursor_3d()


func build_structure_debug(track_coords, kind, size):
	current_track_coords = track_coords
	current_kind = kind
	current_size = size
	build_structure(false)

func delete_structure():
	if current_track_coords in GameManager.track_slots and not GameManager.track_slots[current_track_coords].is_placeholder():
		var m = GameManager.track_slots[current_track_coords]
		GameManager.current_currency += m.cost
		GameManager.track_machines.erase(m)
		for i in GameManager.track_slots:
			if GameManager.track_slots[i] == m:
				if is_instance_valid(m) and not m.is_queued_for_deletion():
					GameManager.pre_delete_machine(m)
					m.queue_free()
				make_track_placeholder(i)
	update_ui()
	Game.play_sfx(delete_sounds.pick_random())
			



enum KIND {STAB, BURN, EEL, FART, HAMMER, FROST, SAW}
func build_structure(discount_currency=true):
	var cost = kind_to_base_cost[current_kind-1] * current_size
	if discount_currency:
		GameManager.current_currency -= cost
	var s: Spatial
	if current_kind in [1,2,5,6,7]:
		for i in current_size:
			match current_kind:
				1:
					s = preload("res://prefabs/StabMachine.tscn").instance()
				2:
					s = preload("res://prefabs/BurnMachine.tscn").instance()
				5:
					s = preload("res://prefabs/HammerMachine.tscn").instance()
				6:
					s = preload("res://prefabs/FrostMachine.tscn").instance()
				7:
					s = preload("res://prefabs/GutMachine.tscn").instance()
				_:
					return
			add_child(s)
			var track_coords = Vector2(current_track_coords.x+i,current_track_coords.y)
			s.position = track_to_world(track_coords) + Vector3(0.5,0,0)
			s.beat = track_coords.x
			s.reposition(int(track_coords.x) % 4)
			s.kind = current_kind
			s.cost = cost
			GameManager.track_slots[track_coords].queue_free()
			GameManager.track_slots[track_coords] = s
			GameManager.track_machines.append(s)
	else:
		match current_kind:
			3:
				s = preload("res://prefabs/EelMachine.tscn").instance()
			4:
				s = preload("res://prefabs/FartMachine.tscn").instance()
			_:
				return
		add_child(s)
		s.position = track_to_world(current_track_coords) + Vector3(0.5,0,0)
		s.reposition(int(current_track_coords.x) % 4)
		for i in current_size:
			GameManager.track_slots[Vector2(current_track_coords.x + i, current_track_coords.y)].queue_free()
			GameManager.track_slots[Vector2(current_track_coords.x + i, current_track_coords.y)] = s
		s.size = current_size
		s.kind = current_kind
		s.cost = cost
		GameManager.track_machines.append(s)
		
	update_ui()
	Game.play_sfx(build_sounds.pick_random())
	if GameManager.current_currency < cost:
		select_size(0,1)
	#for i in current_size:
	#	GameManager.track_slots.erase(Vector2(current_track_coords.x + i, current_track_coords.y))
	
	
	

	
	
func build_structure_():
	var mesh := selection_placeholder.get_node("Mesh") as MeshInstance
	var machine_placeholder := mesh.duplicate() as MeshInstance
	add_child(machine_placeholder)
	machine_placeholder.global_position = mesh.global_position
	machine_placeholder.mesh = machine_placeholder.mesh.duplicate()
	machine_placeholder.mesh.material = machine_placeholder.mesh.material.duplicate()
	machine_placeholder.mesh.material.albedo_color = Color.red
	for i in current_size:
		GameManager.track_slots.erase(Vector2(current_track_coords.x + i, current_track_coords.y))


onready var selection_placeholder = $CursorMeshInstance2x1
onready var track_placeholder = $TrackPlaceholder
onready var track_placeholders = $TrackPlaceholders

func make_track_placeholder(coords):
	var t = track_placeholder.duplicate()
	t.position = track_to_world(coords)
	track_placeholders.add_child(t)
	t.reposition(coords.x)
	t.show()
	GameManager.track_slots[coords] = t

func make_track(track: int):
	get_node("Tracks/Conveyor" + str(track+1)).show()
	get_node("Tracks/SoulMover" + str(track+1)).show()
	get_node("Tracks/ClawMachine" + str(track+1)).show()
	for x in GameManager.track_length:
		make_track_placeholder(Vector2(x,track))
	for i in 4:
		GameManager.other_slots.append([Vector2(i*4, track), get_node("Tracks/Conveyor" + str(track+1))])
		GameManager.other_slots.append([Vector2(i*4, track), get_node("Tracks/SoulMover" + str(track+1))])
	GameManager.other_slots.append([Vector2(12, track-1), get_node("Tracks/ClawMachine" + str(track+1))])

func make_tracks():
	for track in GameManager.track_num:
		get_node("Tracks/Conveyor" + str(track+1)).hide()
		get_node("Tracks/SoulMover" + str(track+1)).hide()
		get_node("Tracks/ClawMachine" + str(track+1)).hide()
	track_placeholder.hide()
	track_placeholders.hide()
	GameManager.track_machines = []
	for i in min(GameManager.track_num, GameManager.tracks_bought):
		make_track(i)

const track_cost = 180
func unlock_track():
	if GameManager.tracks_bought < GameManager.track_num:
		GameManager.current_currency -= track_cost
		make_track(GameManager.tracks_bought)
		GameManager.tracks_bought += 1
		update_ui()
		
func make_machines():
	for i in 4:
		for j in 3:
			var s = preload("res://prefabs/StabMachine.tscn").instance()
			add_child(s)
			s.position = track_to_world(Vector2(i+j*4, 0)) + Vector3(0.5,0,0)
			s.reposition(i)
			GameManager.track_slots[Vector2(i+j*4, 99)] = s

	var s = preload("res://prefabs/BurnMachine.tscn").instance()
	add_child(s)
	s.position = track_to_world(Vector2(12, 0)) + Vector3(0.5,0,0)
	s.reposition(0)
	GameManager.track_slots[Vector2(12, 99)] = s
	GameManager.track_slots[Vector2(13, 99)] = s
	GameManager.track_slots[Vector2(14, 99)] = s
	GameManager.track_slots[Vector2(15, 99)] = s
	GameManager.track_slots[Vector2(0,7)] = $Hammer
	
	
func make_machines2():
	build_structure_debug(Vector2(0,0), 1, 3)
	build_structure_debug(Vector2(0,2), 1, 4)
	build_structure_debug(Vector2(1,1), 5, 3)
	build_structure_debug(Vector2(4,0), 2, 3)
	build_structure_debug(Vector2(8,0), 3, 3)
	build_structure_debug(Vector2(8,1), 3, 4)
	build_structure_debug(Vector2(12,1), 3, 4)
	build_structure_debug(Vector2(12,0), 4, 4)
	
	build_structure_debug(Vector2(7,0), 1, 1)
	build_structure_debug(Vector2(11,0), 1, 1)
	build_structure_debug(Vector2(15,2), 1, 1)
	build_structure_debug(Vector2(12,3), 6, 3)

func make_machines3():
	build_structure_debug(Vector2(0,0), 3, 8)
	build_structure_debug(Vector2(0,1), 3, 16)
	#build_structure_debug(Vector2(4,0), 3, 4)
	#build_structure_debug(Vector2(8,0), 3, 4)

func make_machines4():
	GameManager.current_currency = 0
	build_structure_debug(Vector2(0,0), 1, 4)
	build_structure_debug(Vector2(0,1), 2, 4)
	build_structure_debug(Vector2(4,0), 2, 4)
	#build_structure_debug(Vector2(0,2), 5, 4)
	build_structure_debug(Vector2(0,3), 3, 8)
	build_structure_debug(Vector2(8,3), 5, 8)

func track_to_world(coords: Vector2):
	return Vector3(coords.x - 8, 0, coords.y * -8)

func world_to_track(coords: Vector2):
	return Vector2(coords.x + 8, int((coords.y-3) / -8))

var _coords:=Vector2.ZERO
func move_cursor_3d():
	if not get_viewport() and not (is_building or is_deleting):
		return
	var position_screen = get_viewport().get_mouse_position()
	var plane := Plane.PLANE_XZ
	plane.d = self.position.y
	var camera := get_viewport().get_camera() as Camera
	var intersect = plane.intersects_ray(
		camera.project_ray_origin(position_screen),
		camera.project_ray_normal(position_screen)
	)
	if intersect:
		intersect.x = round(intersect.x - 0.5)
		intersect.y = 1.0
		intersect.z = round(intersect.z )
		intersect.x -= position.x
		intersect.z -= position.z
		var coords = Vector2(int(intersect.x), int(intersect.z))
		if coords == _coords:
			return
		_coords = coords
		var track_coords = world_to_track(coords)
		if track_coords.x <= GameManager.track_length and current_size >= 1:
			track_coords.x = min(track_coords.x, GameManager.track_length - current_size)
		if is_building:
			if check_tile_is_valid(track_coords):
				current_track_coords = track_coords
				selection_placeholder.show()
				selection_placeholder.position = track_to_world(track_coords)
				selection_placeholder.position += Vector3(0.5,1,-2)
				can_build = true
			else:
				selection_placeholder.hide()
				current_track_coords = null
				can_build = false
		elif is_deleting:
			if track_coords in GameManager.track_slots and not GameManager.track_slots[track_coords].is_placeholder():
				var m = GameManager.track_slots[track_coords]
				current_track_coords = track_coords
				var size = m.size
				var mesh := selection_placeholder.get_node("Mesh") as MeshInstance
				mesh.mesh.size.x = size - 0.2
				mesh.position.x = size / 2.0 - 0.5
				selection_placeholder.position = track_to_world(track_coords)
				selection_placeholder.position += Vector3(0.5,1,-2)
				selection_placeholder.show()
				can_build = true
			else:
				selection_placeholder.hide()
				current_track_coords = null
				can_build = false
		
		
func check_tile_is_valid(track_coords: Vector2):
	if not track_coords in GameManager.track_slots:
		return false
	for i in current_size:
		var check_coordinate = Vector2(track_coords.x + i, track_coords.y)
		if not check_coordinate in GameManager.track_slots or not GameManager.track_slots[check_coordinate] is MachineBase or not GameManager.track_slots[check_coordinate].is_placeholder():
			return false
	return true
