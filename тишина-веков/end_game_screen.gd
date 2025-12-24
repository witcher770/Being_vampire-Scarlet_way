extends Control

signal continue_game

func _on_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://сцены/интерфейс/menu.tscn")


func _on_continue_play_pressed() -> void:
	GameState.game_mode = GameState.GameMode.ENDLESS
	GameState.game_completed = false

	# НЕ увеличиваем global level дальше
	GameState.num_global_level = 1

	continue_game.emit()
