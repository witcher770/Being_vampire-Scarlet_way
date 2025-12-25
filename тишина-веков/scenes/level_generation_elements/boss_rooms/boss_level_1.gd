extends Node2D
signal level_finished


const PRELOADS = {
	# Прочие объекты
	"door": preload("res://сцены/элементы для генерации уроней/дверь_от_босса.tscn")
}

func _ready():
		GameState.all_enemies_dead.connect(_on_all_enemies_dead)


func _on_all_enemies_dead():
	spawn_exit_door()
	

func spawn_exit_door():
	var door_inst = PRELOADS.door.instantiate()
	
	door_inst.position = $SpawnExit.position #середина верхней стены комнаты
	add_child(door_inst)
	print("Размещена дверь - выход из комнаты босса")
	door_inst.door_entered.connect(_on_door_entered) # подписываемся на сигнал касания двери
	
	return


func _on_door_entered():
	level_finished.emit() # если игрок вошел в дверь, то посылаем сигнал, что он покинул комнату
	print("Игрок прошёл уровень с боссом!")
