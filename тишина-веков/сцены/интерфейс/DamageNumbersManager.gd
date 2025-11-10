extends Node

# Заранее загружаем сцену числа урона в память, чтобы не грузить ее каждый раз заново
var damage_number_scene = preload("res://сцены/интерфейс/КолличествоПовреждений.tscn")


func show_damage(position: Vector2, amount: int, is_crit: bool = false, is_player: bool = false):
	"""
	Функция которая будет вызываться когда нужно показать число урона
	position - где в мире показать число
	amount - сколько урона
	is_crit - был ли критический удар
	"""
	
	#print('я получил сигнал')
	var dmg_number = damage_number_scene.instantiate() # Создаем экземпляр (копию) заранее загруженной сцены
	add_child(dmg_number) # Добавляем созданное число урона как дочерний нод менеджера

	# Устанавливаем позицию в мировых координатах
	dmg_number.global_position = position
	
	# Запускаем анимацию
	#print("запускаю анимацию")
	dmg_number.get_node("Label").show_damage(amount, is_crit, is_player)
	
	# Автоудаление после анимации
	"""
	Берем AnimationPlayer числа урона
	Подключаемся к сигналу "анимация закончилась"
	Когда анимация заканчивается - удаляем число урона из памяти
	_anim_name - параметр который приходит с сигналом (нам не нужен). 
	Это нужно чтобы дождаться завершения анимации, иначе даление произойдет мгновенно
	
	queue_free() - безопасное удаление нода
	"""
	#dmg_number.get_node("Label").get_node("AnimationNumber").animation_finished.connect(
		#func(_anim_name): 
			#dmg_number.queue_free()
	#)
