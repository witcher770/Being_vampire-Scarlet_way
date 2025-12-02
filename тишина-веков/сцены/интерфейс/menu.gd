extends Node2D


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://сцены/элементы для генерации уроней/узел_генерации.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
