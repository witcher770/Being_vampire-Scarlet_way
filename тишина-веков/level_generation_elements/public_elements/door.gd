extends Node2D

signal door_entered

var is_player_near = false
var player_ref = null


#func _on_Area2D_body_entered(body: Node2D) -> void:


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = true
		player_ref = body
		print("Игрок рядом с дверью")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_ref:
		is_player_near = false
		player_ref = null
		print("Игрок отошёл от двери")


func _process(delta):
	if is_player_near and Input.is_action_just_pressed("взаимодействие"):
		open_door()


func open_door():
	print("Дверь открыта по кнопке")
	door_entered.emit()


#extends Node2D
#
#signal door_entered  # объявляем сигнал
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
		#if body.name == "Игрок":      # проверяем, что это игрок
			#door_entered.emit()   # отправляем сигнал вверх
			#print('send signal door')
