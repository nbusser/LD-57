class_name MainMenu

extends Control

@onready var _2dhand = $"2DHand"
@onready var _video_stream_player: VideoStreamPlayer = $VideoStreamPlayer


func _on_video_stream_player_finished() -> void:
	_stop_video()


func _on_video_stream_player_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		_stop_video()


func _stop_video() -> void:
	_2dhand.show()
	_video_stream_player.hide()


func _on_Start_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_START)


func _on_select_level_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_SELECT_LEVEL)


func _on_Credits_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_CREDITS)


func _on_Quit_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_QUIT)
