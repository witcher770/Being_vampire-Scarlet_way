extends Node2D

signal leave_start_room

func _ready() -> void:
	# подключаюсь к сигналу от двери, те как только дверь пошлет сигнал вызовется функция в скобках
	$"Дверь".door_entered.connect(_on_door_entered) 


func _on_door_entered():
	leave_start_room.emit() # если игрок вошел в дверь, то посылаем сигнал, что он покинул комнату
	print("Игрок прошёл уровень!")
	
