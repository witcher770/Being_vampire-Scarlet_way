extends Node2D

# сигналы
signal level_finished
# @export_group
# задаем размер сетки и количество комнат
@export var size_level = GameState.size_dungeon
@export var num_rooms = GameState.count_rooms

@export var rooms: Array[FloorElementSet]
# Фрагменты коридоров
@export var corridor_vertical: Array[FloorElementSet]
@export var corridor_horizontal: Array[FloorElementSet]
@export var corridor_g: Array[FloorElementSet]
@export var corridor_invert_g: Array[FloorElementSet]
# Входы в комнаты
@export var entrance_top: Array[FloorElementSet]
@export var entrance_right: Array[FloorElementSet]
@export var entrance_down: Array[FloorElementSet]
# Стены для закрытых проходов
@export var wall_top: Array[FloorElementSet]
@export var wall_right: Array[FloorElementSet]
@export var wall_down: Array[FloorElementSet]

@export var enemies: Array[FloorElementSet]

@export var door: Array[FloorElementSet]

# Словарь для хранения всех загружаемых ресурсов
#const PRELOADS = [{
	## Комнаты
	#"room_15_15_1": preload("res://сцены/элементы для генерации уроней/этаж_1/комнаты/комната_15_15_1.tscn"),
	#
	## Фрагменты коридоров
	#"corridor_vertical_8": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/коридор_вертикальный_8.tscn"),
	#"corridor_horizontal_8": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/коридор_горизонтальный_8.tscn"),
	#"corridor_g": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/коридор_г_10_10.tscn"),
	#"corridor_invert_g": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/коридор_перевернутая_г_10_10.tscn"),
	#
	## Входы в комнаты
	#"entrance_top": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/вход_в_комнату_сверху.tscn"),
	#"entrance_right": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/вход_в_комнату_справа.tscn"),
	#"entrance_bottom": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/вход_в_комнату_снизу.tscn"),
	#
	## Стены для закрытых проходов
	#"wall_top": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/вход_сверху_стена.tscn"),
	#"wall_right": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/вход_справа_стена.tscn"),
	#"wall_bottom": preload("res://сцены/элементы для генерации уроней/этаж_1/фрагменты коридоров/вход_снизу_стена.tscn"),
	#
	## Персонажи
	#"enemy_slime": preload("res://сцены/enemies/slime.tscn"),
	#
	## Прочие объекты
	#"door": preload("res://сцены/элементы для генерации уроней/этаж_1/дверь.tscn")
#}, {
	## Комнаты
	#"room_15_15_1": preload("res://сцены/элементы для генерации уроней/этаж_2/комнаты/комната_15_15_1.tscn"),
	#
	## Фрагменты коридоров
	#"corridor_vertical_8": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/коридор_вертикальный_8.tscn"),
	#"corridor_horizontal_8": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/коридор_горизонтальный_8.tscn"),
	#"corridor_g": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/коридор_г_10_10.tscn"),
	#"corridor_invert_g": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/коридор_перевернутая_г_10_10.tscn"),
	#
	## Входы в комнаты
	#"entrance_top": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/вход_в_комнату_сверху.tscn"),
	#"entrance_right": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/вход_в_комнату_справа.tscn"),
	#"entrance_bottom": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/вход_в_комнату_снизу.tscn"),
	#
	## Стены для закрытых проходов
	#"wall_top": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/вход_сверху_стена.tscn"),
	#"wall_right": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/вход_справа_стена.tscn"),
	#"wall_bottom": preload("res://сцены/элементы для генерации уроней/этаж_2/фрагменты коридоров/вход_снизу_стена.tscn"),
	#
	## Персонажи
	#"enemy_slime": preload("res://сцены/враги/lavoviy_слизь.tscn"),
	#
	## Прочие объекты
	#"door": preload("res://сцены/элементы для генерации уроней/этаж_2/дверь.tscn")
#}
#]

var grid_with_rooms = []

var rng_rand = RandomNumberGenerator.new()
var rng_seed = RandomNumberGenerator.new()

const SIZE_TILE: int = 16
const SIZE_CELL: int = 25
const SIZE_ROOM: int = 15
const SIZE_ZONE: Vector2 = Vector2(SIZE_TILE * SIZE_CELL, SIZE_TILE * SIZE_CELL)  # размер зоны в пикселях

func _ready():
	# ошибочные сиды
		# -3984759562172433446 - угловой коридор через комнату
		# 8949200502619799211 - угловой коридор через комнату
		# 6213835094434982300 - выход из тупиковой комнаты
		# -2962645705040086136 - т-перекресток
		#
	var tyt_zadaem_zerno = 0
	rng_seed.seed = -3984759562172433446  # фиксированный сид для воспроизводимости   6954484218641569678 # 12345
	#rng.randomize() # или для случайного сида каждый раз
	rng_rand = rng_seed
	
	var empty_grid = create_grid(size_level)
	grid_with_rooms = gen_pos_rooms(empty_grid.duplicate())
	#var grid_with_connections = create_tree_connectoins(grid_with_rooms)
	var grid_with_connections = build_dungeon_graph(grid_with_rooms)
	calculate_exits(grid_with_connections)
	
	#print_grid(grid_with_rooms, "connections")
	print()
	instantiate_rooms(grid_with_connections)
	instantiate_corridors(grid_with_connections)
	
	GameState.all_enemies_dead.connect(_on_all_enemies_dead)

	#var a = get_neightbours(grid_with_rooms, Vector2(0, 2))
	#print(a)
	#var room_instance = PRELOADS.room_15_15_1.instantiate()
	#room_instance.position = Vector2(0, 0)
	#add_child(room_instance)


func get_element(
	sets: Array[FloorElementSet],
	floor: int
) -> PackedScene:
	for one_set in sets:
		if one_set.floor_index == floor:
			# pick_random системный метод
			return one_set.elements.pick_random()
	return null


func _on_all_enemies_dead():
	spawn_exit_door(grid_with_rooms)


func spawn_exit_door(grid):
	for i in range(size_level):
			for j in range(size_level):
				var cell = grid[i][j]
				if not cell:
					continue
				if cell["room_type"] == "start_room":
					var door_inst = get_element(door, GameState.num_global_level).instantiate()
					
					var global_pos_cell = grid_to_world(cell["position"]) # верхний левый угол ячейки сетки
					var pos_room = Vector2(global_pos_cell.x + SIZE_ZONE.x / 2, global_pos_cell.y + SIZE_ZONE.y / 2) # координаты центра ячейки(комнаты)
					@warning_ignore("integer_division")
					var offset_room_y = Vector2(0, (SIZE_ROOM * SIZE_TILE) / 2) # смещение от центра к верхнему/нижнему краю комнаты					
					
					door_inst.position = pos_room - offset_room_y #середина верхней стены комнаты
					add_child(door_inst)
					print("Размещена дверь - выход из комнаты")
					door_inst.door_entered.connect(_on_door_entered) # подписываемся на сигнал касания двери
					
					return
					


func print_grid(grid: Array, param: String = "position") -> void:
	for i in range(size_level):
		var line: String = ""
		for j in range(size_level):
			var cell = grid[i][j]
			if cell != null:
				line = line + str(cell[param])
			else:
				line = line + " null "
		print(line)


func create_grid(size: int) -> Array:
	var grid: Array = []
	for i in range(size):
		grid.append([])
		for j in range(size):
			grid[i].append(null)
	return grid


func gen_pos_rooms(grid: Array) -> Array:
	# количество позиций для комнат
	var quantity_pos = size_level ** 2
	if num_rooms > quantity_pos:
		num_rooms = quantity_pos
	
	# создаем массив из возможных позиций для комнаты. array - просто последовательность от 0 до ... с шагом 1
	var maybe_pos_rooms = Array(range(0, quantity_pos, 1)) # не включительно
	
	var tyt_use_zerno = 0
	print("Текущее зерно: ", rng_rand.seed)
	for i in range(num_rooms):
		var tuta_munyaem_zerno = 0
		var num_pos = rng_rand.randi_range(0, quantity_pos - 1)  # генерируем позицию для комнаты. генерит включительно, поэтому -1
		
		
		# удаляем из списка возможных позиций комнат ту, куда сейчас ставим
		var index = maybe_pos_rooms.find(num_pos)  # находим индекс элемента
		var pos = maybe_pos_rooms[index] # получаем номер места для комнаты в сетке.
		"""
		в строчке выше было еще написано -1. и это ОЧЕНЬ ОЧЕНЬ СИЛЬНО ломало мне генерацию. 
		ПРЯМ ВООБЩЕ В НУЛИНУ ЛОМАЛО. Генераций без артефактов процентов 30 было всего
		Детали важны
		Пусть этот коментарий останется тут для истории
		"""
		
		# целочисленное деление определяет номер строки, остаток - столбец в этой строке
		# ема я гений конечно, додумался до такого
		var x = int(pos / size_level)
		var y = pos % size_level
		
		var cell_info = {
				"has_room": true, # раз в этой ветке комнату точно создаем, значит она есть. хз пока насколько это нужный параметр
				"room_type": null, # тип комнаты. первую можно сделать стартовой и в ней создавать игрока
				"room_instance": null, # тут должжна быть ссылка на комнату, но ывбор комнаты думаю должен быть позже
				"exits": {"north": false, "south": false, "east": false, "west": false}, # параметры для заполнения пустот в стене
				"connections": [], # Vector2i(1, 0), соединена с комнатой справа (x+1, y+0), Vector2i(0, 1) соединена с комнатой снизу  (x+0, y+1)
				"position": Vector2(x, y) # просто координаты
			}
		# на место ячейки записываем словарь с информацией о ней
		grid[x][y] = cell_info
		
		maybe_pos_rooms.remove_at(index)  # удаляем использованную(уже занятую) позицию
		quantity_pos -= 1 # уменьшаем количество доступных мест

	return grid


func create_tree_connectoins_prim(grid: Array) -> Array: 
	var in_tree = []  # комнаты уже в дереве
	var edges = []    # возможные соединения для добавления
	var cell = []
	var f_room: bool = false
	for i in range(size_level):
		for j in range(size_level):
			cell = grid[i][j]
			if cell:
				var first_room = cell #  первая встреченная комната будет первой
				cell["room_type"] = "start_room"
				f_room = true
				
				# тут добавим игрока
				break
		if f_room:
			break
	
	while in_tree.size() < num_rooms:
		var near_rooms = get_neightbours(grid, cell["position"])
		for near_room in near_rooms:
			var connection: Array = [cell["position"], near_room["position"], cell["position"].distance_to(near_room["position"])]
			edges.append(connection)
		#if edges.size() == 0:
		
		# сортируем массив по возрастанию по дистанции
		edges.sort_custom(func(a, b): return a[2] < b[2])
		var num_conct = 0 # берем первую связь из списка
		
		var pos_room1: Vector2 = edges[num_conct][0]
		var room1 = grid[pos_room1.x][pos_room1.y]
		var pos_room2: Vector2 = edges[num_conct][1]
		var room2 = grid[pos_room2.x][pos_room2.y]
		
		# удаляем из списка связей рассмотренную
		edges.remove_at(num_conct)  # удаляем использованную связь
		
		# записываем им ссылки друг на друга
		room1["connections"].append(pos_room2 - pos_room1) # относительное смещение на вторую комнату
		room2["connections"].append(pos_room1 - pos_room2)
		# не уверен нужно ли это так как при присваивании ссылки но на всякий случай
		# перезаписываем в сетке на комнаты с добавленными связями
		grid[pos_room1.x][pos_room1.y] = room1
		grid[pos_room2.x][pos_room2.y] = room2
		
		# добавляем соединенную комнату в дерево
		if room1 not in in_tree:
			in_tree.append(room1)
			cell = room1
		if room2 not in in_tree:
			in_tree.append(room2)
			cell = room2
	return grid


func create_tree_connectoins(grid: Array) -> Array: 
	var in_tree = []  # комнаты уже в дереве
	var edges = []    # возможные соединения для добавления
	var first_room: bool = true
	
	for i in range(size_level):
		for j in range(size_level):
			var cell = grid[i][j]
			if not cell:
				continue
			if cell in in_tree:
				#continue # если эту комнату уже рассмотре
				pass
			
			# если комната первая, делаем стартовой
			if first_room:
				cell["room_type"] = "start_room"
				
				# создание ноды для размещения игрока через загрузчик уровней
				var s = Node2D.new()
				s.name = "SpawnPoint"
				s.position = grid_to_world(cell["position"]) + Vector2(200, 200)
				add_child(s)
				
				#in_tree.append(cell) # добавляем первую ячейку в дерево
				first_room = false
				
			var near_rooms = get_neightbours(grid, cell["position"])
			for near_room in near_rooms:
				if near_room in in_tree:
					continue # если комната уже в дереве не считаем ее соседом(пропускаем)
				"""
				тут воможно еще стоит добавить расстояние между комнатами, 
				чтобы выбирать наименьшие растояния и проще строить коридоры
				и избегать багов
				"""
				
				var connection: Array = [cell["position"], near_room["position"], cell["position"].distance_to(near_room["position"])]
				edges.append(connection)
			
			# если все соседи уже в дереве пропускаем комнату
			if edges.size() == 0:
				continue 
			## теперь из массива всех связей выберем случайную и сформируем ее
			#var num_conct = rng_rand.randi_range(0,edges.size() - 1)  # выбираем случайную связь. генерит включительно, поэтому -1
			# сортируем массив по возрастанию по дистанции
			edges.sort_custom(func(a, b): return a[2] < b[2])
			var num_conct = 0 # берем первую связь из списка
			
			var pos_room1: Vector2 = edges[num_conct][0]
			var room1 = grid[pos_room1.x][pos_room1.y]
			var pos_room2: Vector2 = edges[num_conct][1]
			var room2 = grid[pos_room2.x][pos_room2.y]
			
			# удаляем из списка связей рассмотренную
			edges.remove_at(num_conct)  # удаляем использованную связь
			
			# записываем им ссылки друг на друга
			room1["connections"].append(pos_room2 - pos_room1) # относительное смещение на вторую комнату
			room2["connections"].append(pos_room1 - pos_room2)
			
			# не уверен нужно ли это так как при присваивании ссылки на переменные но на всякий случай
			# перезаписываем в сетке на комнаты с добавленными связями
			grid[pos_room1.x][pos_room1.y] = room1
			grid[pos_room2.x][pos_room2.y] = room2
			
			# добавляем соединенную комнату в дерево
			if room1 not in in_tree:
				in_tree.append(room1)
			if room2 not in in_tree:
				in_tree.append(room2)
	return grid


func _on_door_entered():
	level_finished.emit() # если игрок вошел в дверь, то посылаем сигнал, что он покинул комнату
	print("Игрок прошёл уровень!")


func get_neightbours(grid: Array, coords: Vector2) -> Array: # возвращает массив соседей - комнат
	var edges = []
	var size_matrix = 3 # изнчально матрица соседей 3 на 3, с переданным элементом в центре
	var maybe_pos_edges = create_grid(size_matrix) # массив возможных позиций(не выходящих за сетку) для отладки
	var depth = 0 # глубина поиска соседей ,кол-во просматриваемых окружностей
	var depth_for_cicle = 1 # нужна чтобы нормализовывать i и j, делая из индексов относит. смещение
	
	for i in range(size_matrix + depth * 2): # изнчально матрица соседей 3 на 3, и каждая следующая откружность на 2 больше
		for j in range(size_matrix + depth * 2):
			@warning_ignore("integer_division")
			var center: int = int(size_matrix / 2)
			if i == center and j == center: # пропускаем ячейку в которой находится сама проверяемая комната
				maybe_pos_edges[i][j] = 0
				continue
			var move_x = i - 1 * depth_for_cicle # смещение по строкам
			var move_y = j - 1 * depth_for_cicle # смещение по столбцам
			
			if coords.x + move_x >= 0 and coords.x + move_x < size_level:
				if coords.y + move_y >= 0 and coords.y + move_y < size_level:
					# если индекс соседа не выходит за пределы сетки(проверки выше),
					maybe_pos_edges[i][j] = 1 
					# то проверяем эту позицию на наличие комнаты в ней
					var cell = grid[coords.x  + move_x][coords.y  + move_y]
					# если комната есть, то добавляем вектор с относительным положением этого соседа
					if cell:
						# edges.append(Vector2(move_x, move_y)) # тут добавляем относительное положение
						edges.append(cell) # добавляем самого соседа
						continue
			maybe_pos_edges[i][j] = 0
	
	#print("возможные позиции соседей")
	#for d in range(3):
		#print(maybe_pos_edges[d])
	
	if edges.size() == 0: # если на соседних клетках соседей нет
		pass # тут должен быть рекурсивный вызов этой же функции с увеличенными параметрами глубины. Требует доработки
		var dorobotka = 0
	
	return edges


func calculate_exits(grid: Array) -> Array:
	for row in grid:
		for cell in row:
			if not cell:
				continue # если ячейки нет, пропускаем ее
			for connection in cell["connections"]:
				# Если в соединении есть 0 значит комната не по диагонали
				if connection.x == 0 or connection.y == 0:
					if connection.x == 0 and connection.y > 0:
						cell["exits"]["east"] = true
					elif connection.x == 0 and connection.y < 0:
						cell["exits"]["west"] = true
					elif connection.y == 0 and connection.x > 0:
						cell["exits"]["south"] = true
					elif  connection.y == 0 and connection.x < 0:
						cell["exits"]["north"] = true
					
				else:
					# комната по диагонали
					if connection.x > 0 and connection.y > 0: # вниз и вправо - перевернутая г
						cell["exits"]["south"] = true
					# та же ситуация, только для 2й комнаты, соединенной перевернутой г
					elif connection.x < 0 and connection.y < 0: # вверх и влево - перевернутая г
						cell["exits"]["west"] = true
					elif connection.x < 0 and connection.y > 0: # вверх вправо - г
						cell["exits"]["north"] = true
					# та же ситуация, только для 2й комнаты, соединенной  г
					elif connection.x > 0 and connection.y < 0: # вниз влево - г
						cell["exits"]["west"] = true
	return grid


func grid_to_world(grid_pos: Vector2) -> Vector2:
	# меняем местами х и у так как в векторе позиции х это положение по строкам, а в мировой сетке это у
	return Vector2(grid_pos.y * SIZE_ZONE.x, grid_pos.x * SIZE_ZONE.y)


func instantiate_rooms(grid: Array) -> Array: # возвращает массив с загруженными асетами комнат
	for i in range(size_level):
		for j in range(size_level):
			var cell = grid[i][j]
			if cell:
				var pos_cell = cell["position"]
				var global_pos_cell = grid_to_world(pos_cell) # верхний левый угол ячейки сетки
				var pos_for_create: Vector2 = Vector2(global_pos_cell.x + SIZE_ZONE.x / 2, global_pos_cell.y + SIZE_ZONE.y / 2) # координаты центра ячейки
				#var room_scene = choose_room_prefab(cell.exits)
				cell["room_instance"] = get_element(rooms, GameState.num_global_level).instantiate()
				cell["room_instance"].position = pos_for_create
				add_child(cell["room_instance"])
				
				# добавляем врагов
				instantiate_enemies(cell)
	
	return grid

func instantiate_enemies(cell: Dictionary) -> void:
	var num_enemies = rng_rand.randi_range(GameState.enemies_in_room - 2, GameState.enemies_in_room)  # генерируем количество врагов
	num_enemies = max(1, num_enemies)
	var dorabotka = 0 # заменить числа на переменные в соответсвии с уровнем сложности
	GameState._enemies_count += num_enemies
	for l in range(num_enemies):
		# генер. коор. х для размещения врага. -2 чтобы не прилипал к стенам и мебели
		# считаем положение врага в локальной ск комнаты, от ее центра
		@warning_ignore("integer_division")
		var coor_x = rng_rand.randi_range(
			int(-SIZE_TILE * (int(SIZE_ROOM / 2) - 2)),
			int(+SIZE_TILE * (int(SIZE_ROOM / 2) - 2)))
		# также y
		@warning_ignore("integer_division")
		var coor_y = rng_rand.randi_range(
				int(-SIZE_TILE * (int(SIZE_ROOM / 2) - 2)),
				int(+SIZE_TILE * (int(SIZE_ROOM / 2) - 2)))
		# инстанцируем
		var enemy_instance = get_element(enemies, GameState.num_global_level).instantiate()
		enemy_instance.position = Vector2(coor_x, coor_y)
		# 
		cell["room_instance"].add_child(enemy_instance)
		var dorabotka1 = 0 # сделать функцию проверки колизий, коректного размещения


func instantiate_corridors(grid: Array) -> Array:
	for i in range(size_level):
		for j in range(size_level):
			var cell = grid[i][j]
			if not cell:
				continue
			
			# расчитываем координаты ячейки
			var pos_cell = cell["position"]
			var global_pos_cell = grid_to_world(pos_cell) # верхний левый угол ячейки сетки
			var pos_room = Vector2(global_pos_cell.x + SIZE_ZONE.x / 2, global_pos_cell.y + SIZE_ZONE.y / 2) # координаты центра ячейки(комнаты)
			var offset_cell_y = Vector2(0, SIZE_ZONE.y / 2) # смещение от центра к верхнему/нижнему краю ячейки
			var offset_cell_x = Vector2(SIZE_ZONE.x / 2, 0)
			@warning_ignore("integer_division")
			var offset_room_y = Vector2(0, (SIZE_ROOM * SIZE_TILE) / 2) # смещение от центра к верхнему/нижнему краю комнаты
			@warning_ignore("integer_division")
			var offset_room_x = Vector2((SIZE_ROOM * SIZE_TILE) / 2, 0) # смещение от центра к верхнему/нижнему краю комнаты
			
			instantiate_exits_walls(cell, pos_room) # рисуем стены там где нет выходов
			
			if i == 1 and j == 1:
				pass
			
			var exits_chek: Array = [false, false, false, false] # для отслеживания какие выходы проверяли. 0 индекс - север и дальше по часовой
			for connection in cell["connections"]: # перебираем связи
				# обычные проверки + проверяем что текущая связь к комнате сверху или сверху справа
				if cell["exits"]["north"] and not exits_chek[0] and (connection.x < 0 and (connection.y == 0 or connection.y > 0)): # если есть выход на север
					exits_chek[0] = true
					# добавляем к комнате выход
					var exit_inst = get_element(entrance_top, GameState.num_global_level).instantiate()
					exit_inst.position = pos_room - offset_room_y
					add_child(exit_inst)
					if connection.y == 0: # прямой вверх - логика урощена при опоре на варианты получения этого выхода из функции расчета выходов
						# меняем знаки, тк связь на эту комнату, от второй комнаты в паре будет с противоположными знаками
						var corridor_up_inst = get_element(corridor_vertical, GameState.num_global_level).instantiate()
						corridor_up_inst.position = pos_room - offset_cell_y
						add_child(corridor_up_inst)
					else: # буква г
						# меняем знаки, тк связь на эту комнату, от второй комнаты в паре будет с противоположными знаками
						instantiate_g_corridor(pos_room)
				# обычные проверки + проверяем что текущая связь к комнате справа
				elif cell["exits"]["east"] and not exits_chek[1] and (connection.x == 0 and connection.y > 0):
					exits_chek[1] = true
					# добавляем к комнате выход
					var exit_inst = get_element(entrance_right, GameState.num_global_level).instantiate()
					exit_inst.position = pos_room + offset_room_x
					add_child(exit_inst)
					# добавляем сам коридор. на восток может идти только прямой коридор
					var corridor_right_inst = get_element(corridor_horizontal, GameState.num_global_level).instantiate()
					corridor_right_inst.position = pos_room + offset_cell_x
					add_child(corridor_right_inst)
				# обычные проверки + проверяем что текущая связь к комнате внизу или внизу справа
				elif cell["exits"]["south"] and not exits_chek[2] and (connection.x > 0 and (connection.y == 0 or connection.y > 0)):
					exits_chek[2] = true
					# добавляем к комнате выход
					var exit_inst = get_element(entrance_down, GameState.num_global_level).instantiate()
					exit_inst.position = pos_room + offset_room_y
					add_child(exit_inst)
					if connection.y == 0: # прямой вниз - логика урощена при опоре на варианты получения этого выхода из функции расчета выходов
						continue # этот коридор уже нарисован - он же с севера вверх
					else: # буква г
						# меняем знаки, тк связь на эту комнату, от второй комнаты в паре будет с противоположными знаками
						instantiate_invert_g_corridor(pos_room)
				elif cell["exits"]["west"] and not exits_chek[3]:
					exits_chek[3] = true
					# добавляем к комнате выход
					var exit_inst = get_element(entrance_right, GameState.num_global_level).instantiate()
					exit_inst.scale.x = -1
					exit_inst.position = pos_room - offset_room_x
					add_child(exit_inst)
	
	return grid


func instantiate_g_corridor(pos_room: Vector2):
	# создаем
	var corridor_up_inst = get_element(corridor_vertical, GameState.num_global_level).instantiate()
	var corridor_right_inst = get_element(corridor_horizontal, GameState.num_global_level).instantiate()
	var corridor_g_inst = get_element(corridor_g, GameState.num_global_level).instantiate()
	# размещаем
	corridor_up_inst.position = pos_room - Vector2(0, SIZE_ZONE.y / 2)
	corridor_g_inst.position = pos_room - Vector2(0, SIZE_ZONE.y)
	corridor_right_inst.position = pos_room - Vector2(0, SIZE_ZONE.y) + Vector2(SIZE_ZONE.x / 2, 0)
	# добавляем
	add_child(corridor_up_inst)
	add_child(corridor_g_inst)
	add_child(corridor_right_inst)


func instantiate_invert_g_corridor(pos_room: Vector2):
	# создаем
	var corridor_up_inst = get_element(corridor_vertical, GameState.num_global_level).instantiate()
	var corridor_right_inst = get_element(corridor_horizontal, GameState.num_global_level).instantiate()
	var corridor_g_inst = get_element(corridor_invert_g, GameState.num_global_level).instantiate()
	# размещаем
	corridor_up_inst.position = pos_room + Vector2(0, SIZE_ZONE.y / 2)
	corridor_g_inst.position = pos_room + Vector2(0, SIZE_ZONE.y)
	corridor_right_inst.position = pos_room + Vector2(0, SIZE_ZONE.y) + Vector2(SIZE_ZONE.x / 2, 0)
	# добавляем
	add_child(corridor_up_inst)
	add_child(corridor_g_inst)
	add_child(corridor_right_inst)


func instantiate_exits_walls(cell, pos_room: Vector2):
	if not cell["exits"]["north"]:
		var exit_inst = get_element(wall_top, GameState.num_global_level).instantiate()
		exit_inst.position = pos_room - Vector2(0, (SIZE_ROOM * SIZE_TILE) / 2)
		add_child(exit_inst)
	if not cell["exits"]["east"]:
		var exit_inst = get_element(wall_right, GameState.num_global_level).instantiate()
		exit_inst.position = pos_room + Vector2((SIZE_ROOM * SIZE_TILE) / 2, 0)
		add_child(exit_inst)
	if not cell["exits"]["south"]:
		var exit_inst = get_element(wall_down, GameState.num_global_level).instantiate()
		exit_inst.position = pos_room + Vector2(0, (SIZE_ROOM * SIZE_TILE) / 2)
		add_child(exit_inst)
	if not cell["exits"]["west"]:
		var exit_inst = get_element(wall_right, GameState.num_global_level).instantiate()
		exit_inst.scale.x = -1
		exit_inst.position = pos_room - Vector2((SIZE_ROOM * SIZE_TILE) / 2, 0)
		add_child(exit_inst)

# процедурная генерация завершена


# новая версия расставления связей от клода
@export var loop_chance: float = 0.5  # 0 = чистое дерево без циклов, 1 = максимум циклов


func build_dungeon_graph(grid: Array) -> Array:
	var all_cells: Array = []
	for i in range(size_level):
		for j in range(size_level):
			if grid[i][j]:
				all_cells.append(grid[i][j])

	# первая найденная комната - стартовая (перенесено как было, без изменений логики)
	if all_cells.size() > 0:
		var start_cell = all_cells[0]
		start_cell["room_type"] = "start_room"
		var s = Node2D.new()
		s.name = "SpawnPoint"
		s.position = grid_to_world(start_cell["position"]) + Vector2(200, 200)
		add_child(s)

	# 1. собираем всех валидных кандидатов-рёбер (без дублей; диагонали - с проверкой угла)
	var candidates: Array = []  # [pos1, pos2, dist]
	var seen_edges: Dictionary = {}

	for cell in all_cells:
		var pos = cell["position"]
		for neighbor in get_neightbours(grid, pos):
			var npos = neighbor["position"]
			var key = _edge_key(pos, npos)
			if seen_edges.has(key):
				continue
			seen_edges[key] = true

			var diff = npos - pos
			if diff.x != 0 and diff.y != 0:
				# диагональ - угловая клетка должна быть физически пустой
				var corner = _diagonal_corner(pos, npos)
				if grid[corner.x][corner.y] != null:
					continue  # там комната - Г-коридор через нее не проведёшь

			candidates.append([pos, npos, pos.distance_to(npos)])

	candidates.sort_custom(func(a, b): return a[2] < b[2])

	# 2. Kruskal: гарантированно связное дерево через DSU
	var parent: Dictionary = {}
	for cell in all_cells:
		parent[cell["position"]] = cell["position"]

	var claimed_corners: Dictionary = {}  # угловые клетки, уже занятые под другой диагональный коридор
	var leftover: Array = [] # массив для лишних ребер - между комнатами, которые уже в одной компоненте связности

	for edge in candidates:
		var diff = edge[1] - edge[0]
		var corner = null
		if diff.x != 0 and diff.y != 0:
			corner = _diagonal_corner(edge[0], edge[1])
			if claimed_corners.has(corner):
				continue  # угол уже занят другим диагональным коридором

		var root1 = _uf_find(parent, edge[0])
		var root2 = _uf_find(parent, edge[1])
		if root1 != root2:
			parent[root1] = root2
			_apply_edge(grid, edge[0], edge[1])
			if corner != null:
				claimed_corners[corner] = true
		else:
			leftover.append(edge)

	# 3. страховка: если компонент больше одной - есть комната совсем без
	# соседей в радиусе 1 клетки (see get_neightbours - там recursive fallback не реализован)
	var roots: Dictionary = {}
	for cell in all_cells:
		roots[_uf_find(parent, cell["position"])] = true
	print(roots.size())
	if roots.size() > 1:
		push_warning("FloorGenerator: %d изолированных групп комнат вместо 1. Сид: %s" % [roots.size(), rng_seed.seed])

	# 4. часть оставшихся валидных рёбер возвращаем как петли (циклы)
	for edge in leftover:
		if rng_rand.randf() >= loop_chance:
			continue
		var diff = edge[1] - edge[0]
		var corner = null
		if diff.x != 0 and diff.y != 0:
			corner = _diagonal_corner(edge[0], edge[1])
			if claimed_corners.has(corner):
				continue
		_apply_edge(grid, edge[0], edge[1])
		if corner != null:
			claimed_corners[corner] = true

	return grid


func _apply_edge(grid: Array, pos1: Vector2, pos2: Vector2) -> void:
	var room1 = grid[pos1.x][pos1.y]
	var room2 = grid[pos2.x][pos2.y]
	room1["connections"].append(pos2 - pos1)
	room2["connections"].append(pos1 - pos2)


func _diagonal_corner(pos1: Vector2, pos2: Vector2) -> Vector2:
	# именно этот угол физически использует instantiate_g_corridor/instantiate_invert_g_corridor
	var west_pos = pos1 if pos1.y < pos2.y else pos2
	var east_pos = pos2 if pos1.y < pos2.y else pos1
	return Vector2(east_pos.x, west_pos.y)


func _edge_key(a: Vector2, b: Vector2) -> String:
	if a.x < b.x or (a.x == b.x and a.y < b.y):
		return "%s|%s" % [a, b]
	return "%s|%s" % [b, a]


func _uf_find(parent: Dictionary, pos: Vector2) -> Vector2:
	var root = pos
	while parent[root] != root:
		root = parent[root]
	var cur = pos
	while parent[cur] != root:
		var next_pos = parent[cur]
		parent[cur] = root
		cur = next_pos
	return root
