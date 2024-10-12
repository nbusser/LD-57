extends Control

var current_level_number = 0
var nb_coins = 0

var current_player: AudioStreamPlayer
var current_scene: set = set_scene

@onready var music_players = $Musics.get_children() as Array[AudioStreamPlayer]

@onready var main_menu = preload("res://src/MainMenu/MainMenu.tscn")
@onready var level = preload("res://src/Level/Level.tscn")
@onready var change_level = preload("res://src/EndLevel/EndLevel.tscn")
@onready var credits = preload("res://src/Credits/Credits.tscn")
@onready var game_over = preload("res://src/GameOver/GameOver.tscn")

@onready var viewport = $SubViewportContainer/SubViewport

# Settings of all levels. To be configured from the editor
@export var levels: Array[LevelData]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_run_main_menu()


func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()


func _on_quit_game():
	get_tree().quit()


func _on_start_game():
	_load_level()


func _on_show_credits():
	_run_credits(true)


func _on_show_main_menu():
	_run_main_menu()


func set_scene(new_scene):
	if current_scene:
		viewport.remove_child(current_scene)
		current_scene.queue_free()

	current_scene = new_scene
	viewport.add_child(current_scene)


func _load_level():
	var scene = level.instantiate()
	scene.init(levels[current_level_number], current_level_number, nb_coins)

	scene.connect("end_of_level", Callable(self, "_on_end_of_level"))
	scene.connect("game_over", Callable(self, "_on_game_over"))

	self.current_scene = scene


func _on_end_of_level():
	if current_level_number + 1 >= 2:
		# Win
		_run_credits(false)
	else:
		_load_end_level()


func first_level():
	return current_level_number == 0


func _on_game_over():
	var scene = game_over.instantiate()

	scene.connect("restart", Callable(self, "_on_restart_level"))
	scene.connect("quit", Callable(self, "_on_quit_game"))

	self.current_scene = scene


func _on_restart_level():
	_load_level()


func _on_restart_select_level():
	_load_end_level()


func _load_end_level():
	var scene = change_level.instantiate()
	scene.init(current_level_number, nb_coins)

	scene.connect("next_level", Callable(self, "_on_next_level"))

	self.current_scene = scene


func _on_next_level():
	current_level_number += 1
	change_music_track(music_players[current_level_number % len(music_players)])
	_load_level()


func _run_credits(can_go_back):
	var scene = credits.instantiate()

	scene.set_back(can_go_back)
	if can_go_back:
		scene.connect("back", Callable(self, "_on_show_main_menu"))

	self.current_scene = scene


func _run_main_menu():
	var scene = main_menu.instantiate()

	change_music_track(music_players[0])

	scene.connect("start_game", Callable(self, "_on_start_game"))
	scene.connect("quit_game", Callable(self, "_on_quit_game"))
	scene.connect("show_credits", Callable(self, "_on_show_credits"))

	self.current_scene = scene


func change_music_track(new_player: AudioStreamPlayer):
	if current_player != new_player:
		for mp in music_players:
			mp.stop()

		new_player.play()
		current_player = new_player
