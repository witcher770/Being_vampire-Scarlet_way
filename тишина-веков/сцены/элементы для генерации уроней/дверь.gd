extends Node2D

signal door_entered  # объявляем сигнал

func _on_area_2d_body_entered(body: Node2D) -> void:
		if body.name == "Игрок":      # проверяем, что это игрок
			door_entered.emit()   # отправляем сигнал вверх
			print('send signal door')
