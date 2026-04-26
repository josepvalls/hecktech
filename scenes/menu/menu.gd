extends Control

var sfx_playing := true
export var disable_leaderboard := false

func _ready():
	$"%PlayButton".grab_focus() # needed for gamepads to work
	$"%PlayButton".connect("pressed", self, "_on_PlayButton_pressed", ["res://scenes/hell/SequencerFactory3.tscn", true])
	#$"%SettingsButton".connect("pressed", self, "_on_SettingsButton_pressed", [true])
	#$"%InstructionsButton".connect("pressed", self, "_on_InstructionsButton_pressed", [true])
	#$"%CloseInstructions".connect("pressed", self, "_on_InstructionsButton_pressed", [false])
	#$"%CloseSettings".connect("pressed", self, "_on_SettingsButton_pressed", [false])
	#$"%ExitButton".connect("pressed", self, "_on_ExitButton_pressed")
	#$"%CloseLeaderboard".connect("pressed", $LeaderboardLayer, "hide")
	#$"%LeaderboardButton".connect("pressed", $LeaderboardLayer, "show")
	
	prints(GameServices.user_data.player_name.strip_edges(), GameServices.user_data.player_name.strip_edges() == "Anonymous")
	if GameServices.user_data.player_name.strip_edges() == "Anonymous":
		randomize()
		GameServices.user_data.player_name = "Anonymous " + str(randi() % 999)
		
	#prints(Game.settings.player_name.strip_edges(), Game.settings.player_name.strip_edges() == "Anonymous")
	
	if OS.has_feature('HTML5'):
		$"%ExitButton".queue_free()
		$"%PlayButton3".queue_free()
		
	$AudioStreamPlayerSFX.connect("finished", self, "play_sfx")
	#$SettingsLayer.hide()
	#$LeaderboardLayer.hide()
	var version = load("res://version.gd").VERSION
	$Credits/Developer.text += "\nv." + str(version)
	play_sfx()
	
	
const sfx_sounds_ = [
	preload("res://assets/sfx/Imp Positive/1.ogg"),
	preload("res://assets/sfx/Imp Positive/2.ogg"),
	preload("res://assets/sfx/Imp Positive/3.ogg"),
	preload("res://assets/sfx/Imp Positive/4.ogg"),
	preload("res://assets/sfx/Imp Negative/1.ogg"),
	preload("res://assets/sfx/Imp Negative/2.ogg"),
	preload("res://assets/sfx/Imp Negative/4.ogg"),
	preload("res://assets/sfx/Imp Negative/5.ogg"),
	preload("res://assets/sfx/Imp Negative/6.ogg"),
]

const sfx_sounds = [
	preload("res://assets/sfx/Drum One Shots/b2.wav"), 
	preload("res://assets/sfx/Drum One Shots/f1.wav"), 
	preload("res://assets/sfx/Drum One Shots/f2.wav")
	]

func play_sfx():
	if sfx_playing:
		$AudioStreamPlayerSFX.stream = sfx_sounds.pick_random()
		$AudioStreamPlayerSFX.play()

func _on_SettingsButton_pressed(visibility: bool) -> void:
	sfx_playing = visibility
	$"%VBoxSoundSettings".refresh()
	$SettingsLayer.visible = visibility
	if visibility:
		play_sfx()
	else:
		Game.write_settings()

func _on_InstructionsButton_pressed(visibility: bool) -> void:
	sfx_playing = visibility
	$InstructionsLayers.visible = visibility

func _on_PlayButton_pressed(scene, tutorial) -> void:
	sfx_playing = false
	var params = {
		show_progress_bar = true,
		"tutorial": tutorial,
	}
	Game.change_scene(scene, params)


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		yield(transitions.anim, "animation_finished")
		yield(get_tree().create_timer(0.3), "timeout")
	get_tree().quit()
