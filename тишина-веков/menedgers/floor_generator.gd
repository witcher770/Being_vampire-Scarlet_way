extends Node2D

#Полезные теги
#[param имя_параметра] — описывает аргумент функции.
#[br] — добавляет перенос строки.[
#code]текст[/code] — выделяет код или названия переменных моноширинным шрифтом.
#@deprecated — помечает функцию устаревшей.
#@experimental — помечает функцию экспериментальной

# сигналы
signal level_finished

# @export_group
# задаем размер сетки и количество комнат
@export var size_level = GameState.size_dungeon
@export var num_rooms = GameState.count_rooms

@export var rooms: Array[FloorElementSet]
#@export_group ('Фрагменты коридоров')
@export var corridor_vertical: Array[FloorElementSet]
@export var corridor_horizontal: Array[FloorElementSet]
@export var corridor_g: Array[FloorElementSet]
@export var corridor_invert_g: Array[FloorElementSet]
@export var corridor_filler_vertical: Array[FloorElementSet]
@export var corridor_filler_horizontal: Array[FloorElementSet]
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

@export var max_generation_attempts: int = 10
var _fully_connected: bool = true

func _ready():
	# ошибочные сиды
		# -3984759562172433446 - угловой коридор через комнату
		# 8949200502619799211 - угловой коридор через комнату
		# 6213835094434982300 - выход из тупиковой комнаты
		# -2962645705040086136 - т-перекресток
	
	rng_seed.seed = -2962645705040086136  # фиксированный сид для воспроизводимости   6954484218641569678 # 12345
	# чтобы включить фиксированный сид снять коментарий ниже
	#rng_rand = rng_seed
	
	generate_dungeon()
	
	GameState.all_enemies_dead.connect(_on_all_enemies_dead)


func generate_dungeon() -> void:
	var grid_with_connections: Array = []
	var attempt := 0

	while true:
		attempt += 1

		var empty_grid = create_grid(size_level)
		grid_with_rooms = gen_pos_rooms(empty_grid.duplicate())
		grid_with_connections = build_dungeon_graph(grid_with_rooms)

		if _fully_connected:
			break
		if attempt >= max_generation_attempts:
			push_error("FloorGenerator: не удалось сгенерировать связный уровень за %d попыток" % attempt)
			break

		print("FloorGenerator: попытка #%d не связалась полностью, пробую новый сид" % attempt)
		rng_rand.randomize()

	_spawn_start_point(grid_with_connections)
	calculate_exits(grid_with_connections)
	instantiate_rooms(grid_with_connections)
	instantiate_corridors(grid_with_connections)


func _spawn_start_point(grid: Array) -> void:
	for row in grid:
		for cell in row:
			if cell and cell["room_type"] == "start_room":
				var s = Node2D.new()
				s.name = "SpawnPoint"
				s.position = grid_to_world(cell["position"]) + Vector2(200, 200)
				add_child(s)
				return



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

## Случайно расставляет комнаты по логической сетке размером size_level x size_level.
## [br][br]
## ВАЖНО: позиция комнаты хранится как Vector2(row, col) в МАТРИЧНОЙ нотации -
## .x это номер СТРОКИ, .y это номер СТОЛБЦА (как в grid[i][j]).
## Это НЕ мировые координаты Godot (там Vector2.x - горизонталь, Vector2.y - вертикаль). [br]
## Перевод между этими двумя системами координат делает grid_to_world() - см. её комментарий.
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
		var x = int(pos / size_level) # номер СТРОКИ (row)
		var y = pos % size_level      # номер СТОЛБЦА (col)
		
		var cell_info = {
				"has_room": true, # раз в этой ветке комнату точно создаем, значит она есть. хз пока насколько это нужный параметр
				"room_type": null, # тип комнаты. первую можно сделать стартовой и в ней создавать игрока
				"room_instance": null, # тут должжна быть ссылка на комнату, но ывбор комнаты думаю должен быть позже
				"exits": {"north": false, "south": false, "east": false, "west": false}, # параметры для заполнения пустот в стене
				"connections": [], # Vector2i(1, 0), соединена с комнатой справа (x+1, y+0), Vector2i(0, 1) соединена с комнатой снизу  (x+0, y+1)
				"position": Vector2(x, y) # Vector2(row, col) - НЕ мировые x/y! см. grid_to_world()
			}
		# на место ячейки записываем словарь с информацией о ней
		grid[x][y] = cell_info
		
		maybe_pos_rooms.remove_at(index)  # удаляем использованную(уже занятую) позицию
		quantity_pos -= 1 # уменьшаем количество доступных мест

	return grid

## @deprecated
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


## @deprecated
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


## Переводит логическую позицию комнаты Vector2(row, col) в мировые координаты Godot.
## [br]
## Единственное место во всём коде, где строка/столбец сетки превращаются
## в горизонталь/вертикаль мира - отсюда свап осей местами: [br]
## - движение по СТРОКАМ сетки (row = grid_pos.x) физически означает движение
##   вверх/вниз -> идёт в мировой Y [br]
## - движение по СТОЛБЦАМ сетки (col = grid_pos.y) физически означает движение
##   влево/вправо -> идёт в мировой X
## [br]
## При отладке на бумаге/логике всегда работаем в системе (row, col) сетки,
## а не в мировой (x, y) - легко перепутать, где на самом деле "право" и "лево".
func grid_to_world(grid_pos: Vector2) -> Vector2:
	# меняем местами х и у так как в векторе позиции х это положение по строкам, а в мировой сетке это у
	# меняем местами row/col на мировые x/y, т.к. это две разные системы координат
	return Vector2(grid_pos.y * SIZE_ZONE.x, grid_pos.x * SIZE_ZONE.y)
	#              ^ col -> мировой X          ^ row -> мировой Y

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
			
			_instantiate_exits_walls(cell, pos_room) # рисуем стены там где нет выходов
			
			if i == 1 and j == 1:
				pass # зачем тут это
			
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
						_place_straight_run(pos_room, Vector2(0, -1), int(-connection.x), corridor_vertical, corridor_filler_vertical)
					else: # буква г
						# меняем знаки, тк связь на эту комнату, от второй комнаты в паре будет с противоположными знаками
						instantiate_g_corridor(pos_room, connection)
				
				# обычные проверки + проверяем что текущая связь к комнате справа
				elif cell["exits"]["east"] and not exits_chek[1] and (connection.x == 0 and connection.y > 0):
					exits_chek[1] = true
					# добавляем к комнате выход
					var exit_inst = get_element(entrance_right, GameState.num_global_level).instantiate()
					exit_inst.position = pos_room + offset_room_x
					add_child(exit_inst)
					# добавляем сам коридор. на восток может идти только прямой коридор
					_place_straight_run(pos_room, Vector2(1, 0), int(connection.y), corridor_horizontal, corridor_filler_horizontal)
				
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
						instantiate_invert_g_corridor(pos_room, connection)
				
				elif cell["exits"]["west"] and not exits_chek[3]:
					exits_chek[3] = true
					# добавляем к комнате выход
					var exit_inst = get_element(entrance_right, GameState.num_global_level).instantiate()
					exit_inst.scale.x = -1
					exit_inst.position = pos_room - offset_room_x
					add_child(exit_inst)
	
	return grid


func instantiate_g_corridor(pos_room: Vector2, connection: Vector2) -> void:
	var n = int(-connection.x)  # шагов вверх
	var m = int(connection.y)   # шагов вправо
	
	_place_straight_run(pos_room, Vector2(0, -1), n, corridor_vertical, corridor_filler_vertical)
	
	var corner_pos = pos_room + Vector2(0, -1) * SIZE_ZONE * n
	var corridor_g_inst = get_element(corridor_g, GameState.num_global_level).instantiate()
	corridor_g_inst.position = corner_pos
	add_child(corridor_g_inst)
	
	_place_straight_run(corner_pos, Vector2(1, 0), m, corridor_horizontal, corridor_filler_horizontal)


func instantiate_invert_g_corridor(pos_room: Vector2, connection: Vector2) -> void:
	var n = int(connection.x)  # шагов вниз
	var m = int(connection.y)  # шагов вправо
	
	_place_straight_run(pos_room, Vector2(0, 1), n, corridor_vertical, corridor_filler_vertical)
	
	var corner_pos = pos_room + Vector2(0, 1) * SIZE_ZONE * n
	var corridor_g_inst = get_element(corridor_invert_g, GameState.num_global_level).instantiate()
	corridor_g_inst.position = corner_pos
	add_child(corridor_g_inst)
	
	_place_straight_run(corner_pos, Vector2(1, 0), m, corridor_horizontal, corridor_filler_horizontal)


func _instantiate_exits_walls(cell, pos_room: Vector2):
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


## Ставит прямой участок коридора длиной count ячеек, начиная от origin в направлении dir.
## Для count=1 (соседние ячейки) ведёт себя ровно как раньше - один бордюр, ноль филлеров. [br]
## [param origin] - Вектор с координатами в пикселях центра комнаты (и ячейки для углового коридора) [br]
## [param dir] - Вектор (0; +/-1) или (+/-1; 0). Указывает направление коридора [br]
## [param count] - Длина коридора (колличество переходов между ячейками). Удобно передавать нужную координату
## из [connection] [br]
## [param border_set] - Передаем нужный набор для отрисовки конкретного направления [br]
## [param filler_set] - Передаем нужный набор для отрисовки конкретного направления [br]
func _place_straight_run(origin: Vector2, dir: Vector2, count: int, border_set: Array, filler_set: Array) -> void:
	# Должно быть всегда положительным. Не отвечает за направление, только кол-во ячеек
	count = abs(count)
	for k in range(1, count + 1):
		var border_tile = get_element(border_set, GameState.num_global_level).instantiate()
		
		# По координатам ставится ровно на пересечении ячеек. dir обнуляет лишнюю координату SIZE_ZONE
		border_tile.position = origin + dir * SIZE_ZONE * (k - 0.5)
		add_child(border_tile)
	
	for k in range(1, count):
		var filler_tile = get_element(filler_set, GameState.num_global_level).instantiate()
		
		# По координатам ставится ровно по центру ячеек. dir обнуляет лишнюю координату SIZE_ZONE
		filler_tile.position = origin + dir * SIZE_ZONE * k
		add_child(filler_tile)


# процедурная генерация завершена


# ============================================================
# ШАНС ДОБАВЛЕНИЯ ДОПОЛНИТЕЛЬНЫХ СВЯЗЕЙ / ЦИКЛОВ
# ============================================================
#
# Определяет вероятность того, что после построения основного
# связного дерева будут добавлены дополнительные рёбра.
#
# Тип:
#   float
#
# Значение:
#   0.0 -> дополнительные циклы никогда не добавляются.
#   1.0 -> каждое подходящее оставшееся ребро добавляется,
#          если оно также проходит все проверки занятости пути.
#
# Значение по умолчанию:
#   0.5 -> вероятность добавления каждого оставшегося ребра
#          составляет примерно 50%.
#
# ВАЖНО:
# loop_chance НЕ управляет построением основного дерева.
# Основные необходимые связи строятся алгоритмом Kruskal независимо от этого параметра.
@export var loop_chance: float = 0.5


## Строит связи между комнатами, находящимися в grid.
## Входные параметры:
##   [grid]: Array
##       Двумерный массив клеток уровня.
## Возвращаемое значение:
##   [Array]
##       Тот же массив grid после добавления связей
##       между комнатами.
func build_dungeon_graph(grid: Array) -> Array:
	_fully_connected = true
	## Массив всех существующих комнат уровня. Сюда будут помещены только те элементы grid,
	## которые существуют, то есть grid[i][j] не равен null.
	var all_cells: Array = []

	# Перебираем все строки сетки.
	for i in range(size_level):
		# Перебираем все столбцы текущей строки.
		for j in range(size_level):
			# Если в данной клетке есть комната,
			# добавляем сам объект комнаты в all_cells.
			if grid[i][j]:
				all_cells.append(grid[i][j])

	# Логика выбора стартовой комнаты здесь не меняется.
	if all_cells.size() > 0:
		# Получаем первую найденную комнату.
		var start_cell = all_cells[0]
		start_cell["room_type"] = "start_room"

	# Здесь формируется список кандидатов на соединение комнат.
	# Каждое ребро хранится в виде:
	#     [pos1, pos2, distance]
	# где:
	#     pos1     - координаты первой комнаты;
	#     pos2     - координаты второй комнаты;
	#     distance - расстояние между комнатами.
	## candidates:
	##     список всех допустимых потенциальных связей.
	var candidates: Array = []
	## seen_edges:
	##     Dictionary, используемый для удаления дублей.
	var seen_edges: Dictionary = {}

	# Перебираем все существующие комнаты.
	for cell in all_cells:
		## Получаем координаты текущей комнаты.
		var pos = cell["position"]
		# Получаем соседей текущей комнаты.
		# Функция get_neightbours() определяет, какие комнаты потенциально могут быть соединены с текущей.
		for neighbor in get_neightbours(grid, pos):
			## Получаем координаты найденного соседа.
			var npos = neighbor["position"]
			## Создаём уникальный ключ для пары комнат.
			var key = _edge_key(pos, npos)

			# Если такое ребро уже встречалось, повторно его не добавляем.
			if seen_edges.has(key):
				continue

			# Запоминаем, что это ребро уже обработано.
			seen_edges[key] = true

			# Добавляем потенциальную связь в список кандидатов.
			# В отличие от старой версии, здесь больше нет отдельной проверки только
			# диагонального угла: окончательная проверка физической проходимости
			# выполняется позже через _straight_path_clear() / _diagonal_path_clear().
			candidates.append([pos, npos, pos.distance_to(npos)])

	# Сортируем все потенциальные связи по расстоянию.
	# После сортировки самые короткие рёбра находятся раньше, а более длинные — позже.
	# Это необходимо для алгоритма Kruskal: он рассматривает рёбра от самых дешёвых к самым дорогим.
	candidates.sort_custom(func(a, b): return a[2] < b[2])

	# 2. KRUSKAL + DSU
	# Здесь непосредственно строится основное связное дерево.
	# Идея Kruskal:
	#   - взять самое короткое доступное ребро;
	#   - если оно соединяет разные компоненты — добавить его;
	#   - если компоненты уже соединены — не добавлять, потому что это создало бы цикл.
	#
	# Для быстрого определения того, находятся ли две комнаты уже в одной компоненте,
	# используется DSU (Disjoint Set Union / система непересекающихся множеств).

	var parent: Dictionary = {}

	# Изначально каждая комната является отдельной компонентой.
	for cell in all_cells:
		parent[cell["position"]] = cell["position"]

	## Общий реестр занятости.
	## В отличие от старого claimed_corners здесь хранятся сразу два типа ресурсов:
	##   - Vector2 -> занятая угловая клетка диагонального коридора;
	##   - String  -> занятый элементарный отрезок между соседними клетками.
	## Это позволяет запрещать не только повторное использование диагонального угла,
	## но и пересечение уже построенного коридора тем же сегментом.
	var claimed: Dictionary = {}

	## Здесь будут храниться рёбра, которые Kruskal не использовал,
	## потому что их концы уже находились в одной компоненте.
	## Именно из этого массива потом будут случайно добавляться дополнительные связи / циклы.
	var leftover: Array = []

	# Перебираем все рёбра в порядке увеличения расстояния.
	for edge in candidates:
		# Вычисляем разницу между координатами концов ребра.
		var diff = edge[1] - edge[0]
		# Одновременное отличие X и Y означает, что связь диагональная.
		var is_diagonal = diff.x != 0 and diff.y != 0

		# Проверяем, можно ли физически проложить путь между комнатами.
		# Для прямого ребра проверяется вся последовательность элементарных сегментов.
		# Для диагонального сначала проверяется угловая клетка, а затем оба прямых "плеча" Г-образного пути.
		# В обоих случаях учитываются уже занятые клетки/сегменты из общего claimed.
		var path_clear = _diagonal_path_clear(grid, claimed, edge[0], edge[1]) if is_diagonal \
			else _straight_path_clear(grid, claimed, edge[0], edge[1])
		if not path_clear:
			continue

		# Находим корень компоненты первой комнаты.
		## _uf_find() проходит по parent и определяет, к какой компоненте принадлежит позиция.
		var root1 = _uf_find(parent, edge[0])

		# Аналогично находим компоненту второй комнаты.
		var root2 = _uf_find(parent, edge[1])

		# Если корни разные, значит комнаты находятся в разных компонентах. Следовательно, соединение
		# этих комнат НЕ создаёт цикл, а наоборот объединяет две независимые части графа.
		if root1 != root2:
			# Объединяем две компоненты. Теперь root1 указывает на root2.
			parent[root1] = root2

			# Фактически добавляем связь между двумя комнатами.
			# Эта функция записывает направление соединения одновременно в обе комнаты.
			_apply_edge(grid, edge[0], edge[1])

			# Запоминаем все физические части созданного пути в claimed,
			# чтобы последующие коридоры не использовали их повторно.
			if is_diagonal:
				_mark_diagonal_path(claimed, edge[0], edge[1])
			else:
				_mark_straight_run(claimed, edge[0], edge[1])

		# Если root1 == root2, обе комнаты уже находятся в одной компоненте. Поэтому добавление
		# такого ребра создало бы цикл. Пока мы его НЕ добавляем. Вместо этого откладываем его в leftover.
		else:
			leftover.append(edge)

	# 3. ПРОВЕРКА СВЯЗНОСТИ
	## После Kruskal ожидается, что все комнаты окажутся в одной компоненте. Если компонентов больше
	## одной, значит некоторые комнаты или группы комнат не удалось соединить допустимыми рёбрами.
	var roots: Dictionary = {}

	# Для каждой комнаты определяем текущий корень её компоненты.
	for cell in all_cells:
		# Использование корня как ключа Dictionary позволяет получить множество уникальных компонент.
		# Например:
		#     A -> root X
		#     B -> root X
		#     C -> root Y
		#
		# roots станет:
		#     X -> true
		#     Y -> true
		# То есть roots.size() == 2.
		roots[_uf_find(parent, cell["position"])] = true

	# Если компонент больше одной, весь граф не является связным.
	if roots.size() > 1:
		print("FloorGenerator: %d изолированных групп, пробую связать доп. коридором. Сид: %s" % [roots.size(), rng_rand.seed])

	# Даже если после основного прохода осталась одна компонента,
	# функция безопасно завершится сразу. Если компонентов несколько,
	# она ищет ближайшее допустимое соединение между ними.
	_connect_remaining_components(grid, parent, all_cells, claimed)

	# 4. ДОБАВЛЕНИЕ ДОПОЛНИТЕЛЬНЫХ РЁБЕР / ЦИКЛОВ
	# leftover содержит рёбра, которые не понадобились для построения основного связного дерева.
	# Такие рёбра потенциально могут создать циклы. Функция _adding_cycle_edges()
	# с вероятностью loop_chance решает, какие из таких рёбер вернуть обратно.
	# Дополнительно перед добавлением повторно проверяется, свободен ли физический путь.
	_adding_cycle_edges(grid, leftover, claimed)

	# Возвращаем исходный grid, внутри которого уже изменены данные комнат и их connections.
	return grid


## Соединение двух комнат - добавление им связей друг с другом.
## Функция меняет только массивы connections у двух комнат:
## для первой добавляется направление к второй, для второй — обратное направление.
func _apply_edge(grid: Array, pos1: Vector2, pos2: Vector2) -> void:
	var room1 = grid[pos1.x][pos1.y]
	var room2 = grid[pos2.x][pos2.y]
	room1["connections"].append(pos2 - pos1)
	room2["connections"].append(pos1 - pos2)


## Создаёт строковый ключ для пары комнат.
## Входные параметры:
##   [a]: Vector2 - Координаты первой комнаты.
##   [b]: Vector2 - Координаты второй комнаты.
## Возвращаемое значение:
##   String
##       Уникальное строковое представление пары координат.
##
## Порядок координат нормализуется, поэтому пара A-B и пара B-A
## получают один и тот же ключ. Это используется для удаления дублей кандидатов.
func _edge_key(a: Vector2, b: Vector2) -> String:
	if a.x < b.x or (a.x == b.x and a.y < b.y):
		return "%s|%s" % [a, b]
	return "%s|%s" % [b, a]


## ПОИСК КОРНЯ КОМПОНЕНТЫ В DSU
## Находит корень множества, которому принадлежит pos.
## Входные параметры:
##   parent: Dictionary
##       Структура DSU.
##       Для каждой позиции хранится её "родитель":
##           parent[position] = parent_position
##       Если:
##           parent[position] == position
##       то position является корнем своей компоненты.
##   pos: Vector2
##       Координаты комнаты, для которой необходимо найти корень компоненты.
## Возвращаемое значение:
##   Vector2
##       Корень компоненты, к которой относится pos.
## Функция реализует две операции:
##   1. Поиск корня.
##   2. Path Compression (сжатие пути). Сжатие пути нужно для ускорения последующих поисков.
func _uf_find(parent: Dictionary, pos: Vector2) -> Vector2:
	# Начинаем поиск с самой переданной позиции.
	var root = pos

	# Пока текущий элемент не является собственным родителем, поднимаемся вверх по дереву родителей.
	while parent[root] != root:
		# Переходим к родителю текущего элемента.
		root = parent[root]

	# Теперь root содержит настоящий корень компоненты. Далее начинается path compression.
	# Идея:
	# Если было:
	#     A -> B -> C -> D
	# где D — корень,
	# то после сжатия пути хотим получить:
	#     A -> D
	#     B -> D
	#     C -> D
	#     D -> D
	# Это делает будущие вызовы _uf_find() намного быстрее. Начинаем снова с исходной позиции.
	var cur = pos
	# Идём по цепочке родителей до корня.
	while parent[cur] != root:
		# Запоминаем текущего родителя,
		# прежде чем изменить parent[cur].
		var next_pos = parent[cur]

		# Напрямую соединяем текущий элемент с корнем.
		parent[cur] = root

		# Переходим к следующему элементу старой цепочки.
		cur = next_pos
	# Возвращаем корень компоненты.
	return root


# ОПРЕДЕЛЕНИЕ УГЛОВОЙ КЛЕТКИ ДЛЯ ДИАГОНАЛЬНОЙ СВЯЗИ
## Определяет клетку, через которую проходит Г-образный
## коридор между двумя диагонально расположенными комнатами. [br]
## Входные параметры: [br]
##   [param pos1]: Vector2 - Координаты первой комнаты. [br]
##   [param pos2]: Vector2 - Координаты второй комнаты. [br]
## Возвращаемое значение: [br]
##   [param Vector2] - Координаты угловой клетки. [br]
## Эта функция предполагает, что между двумя комнатами,
## расположенными по диагонали, коридор использует одну промежуточную угловую клетку.
func _diagonal_corner(pos1: Vector2, pos2: Vector2) -> Vector2:
	# именно этот угол физически используется Г-образным коридором.
	# Выбираем точку с меньшим Y.
	# Если pos1.y < pos2.y:
	#     west_pos = pos1
	#     east_pos = pos2
	# иначе:
	#     west_pos = pos2
	#     east_pos = pos1
	# Названия west/east здесь являются внутренним обозначением и зависят от системы координат конкретного проекта.
	var west_pos = pos1 if pos1.y < pos2.y else pos2
	var east_pos = pos2 if pos1.y < pos2.y else pos1

	# Формируем координату угла:
	# X берём от east_pos.
	# Y берём от west_pos.
	# Получается одна из двух клеток, расположенных между диагональными комнатами.
	return Vector2(east_pos.x, west_pos.y)


## Проверяет, что прямой путь (одна строка ИЛИ один столбец) свободен.
##
## Путь считается свободным, если:
##   1. ни один внутренний элемент пути не содержит комнату;
##   2. ни один элементарный отрезок между соседними клетками уже не занят в claimed.
##
## Эта проверка работает не только для соседних клеток, но и для связи любой длины.
func _straight_path_clear(grid: Array, claimed: Dictionary, pos_a: Vector2, pos_b: Vector2) -> bool:
	# Определяем, идут ли обе точки вдоль одной строки/оси X сетки.
	var along_row := pos_a.x == pos_b.x

	# Выделяем диапазон координат, по которому будем шагать.
	# Если точки лежат на одной строке, меняется Y; иначе меняется X.
	var lo: int = int(min(pos_a.y, pos_b.y)) if along_row else int(min(pos_a.x, pos_b.x))
	var hi: int = int(max(pos_a.y, pos_b.y)) if along_row else int(max(pos_a.x, pos_b.x))

	# Каждая итерация рассматривает один элементарный сегмент
	# между двумя соседними клетками: cell_a -> cell_b.
	for k in range(lo, hi):
		var cell_a: Vector2 = Vector2(pos_a.x, k) if along_row else Vector2(k, pos_a.y)
		var cell_b: Vector2 = Vector2(pos_a.x, k + 1) if along_row else Vector2(k + 1, pos_a.y)

		# Если этот сегмент уже был использован другим коридором,
		# прокладывать по нему новый путь нельзя.
		if claimed.has(_edge_key(cell_a, cell_b)):
			return false

		# Конечные комнаты могут находиться на концах пути, поэтому
		# проверять занятость самой первой клетки не нужно.
		# Для k > lo проверяем внутреннюю клетку маршрута.
		if k > lo and grid[cell_a.x][cell_a.y] != null:
			return false

	return true


## Помечает все элементарные сегменты прямого коридора как занятые.
## После этого другой путь, который пытается использовать хотя бы один
## из этих сегментов, не пройдёт _straight_path_clear().
func _mark_straight_run(claimed: Dictionary, pos_a: Vector2, pos_b: Vector2) -> void:
	var along_row := pos_a.x == pos_b.x
	var lo: int = int(min(pos_a.y, pos_b.y)) if along_row else int(min(pos_a.x, pos_b.x))
	var hi: int = int(max(pos_a.y, pos_b.y)) if along_row else int(max(pos_a.x, pos_b.x))

	for k in range(lo, hi):
		var cell_a: Vector2 = Vector2(pos_a.x, k) if along_row else Vector2(k, pos_a.y)
		var cell_b: Vector2 = Vector2(pos_a.x, k + 1) if along_row else Vector2(k + 1, pos_a.y)
		claimed[_edge_key(cell_a, cell_b)] = true


## Проверяет, можно ли провести Г-образный диагональный путь между двумя комнатами.
##
## Сначала определяется единственная промежуточная угловая клетка.
## Она должна быть свободна от комнаты и не должна быть уже занята другим диагональным путём.
## Затем оба прямых участка до угла проходят ту же проверку, что и обычный прямой коридор.
func _diagonal_path_clear(grid: Array, claimed: Dictionary, pos_a: Vector2, pos_b: Vector2) -> bool:
	# Находим промежуточную угловую клетку Г-образного пути.
	var corner = _diagonal_corner(pos_a, pos_b)

	# Угол нельзя использовать, если в нём уже есть комната
	# или если этот угол уже занят другим диагональным коридором.
	if grid[corner.x][corner.y] != null or claimed.has(corner):
		return false

	# Определяем две крайние точки относительно правила, используемого _diagonal_corner().
	var west_pos = pos_a if pos_a.y < pos_b.y else pos_b
	var east_pos = pos_b if pos_a.y < pos_b.y else pos_a

	# Г-образный путь состоит из двух прямых плеч:
	# west_pos -> corner и corner -> east_pos.
	# Оба участка должны быть свободны от комнат и занятых сегментов.
	return _straight_path_clear(grid, claimed, west_pos, corner) \
		and _straight_path_clear(grid, claimed, corner, east_pos)


## Помечает все ресурсы, которые занимает диагональный Г-образный путь:
## сначала угловую клетку, затем два прямых плеча.
func _mark_diagonal_path(claimed: Dictionary, pos_a: Vector2, pos_b: Vector2) -> void:
	var corner = _diagonal_corner(pos_a, pos_b)
	claimed[corner] = true

	var west_pos = pos_a if pos_a.y < pos_b.y else pos_b
	var east_pos = pos_b if pos_a.y < pos_b.y else pos_a

	_mark_straight_run(claimed, west_pos, corner)
	_mark_straight_run(claimed, corner, east_pos)


# ДОБАВЛЕНИЕ ДОПОЛНИТЕЛЬНЫХ РЁБЕР / ЦИКЛОВ
## Обрабатывает рёбра, которые не понадобились алгоритму Kruskal для построения основного дерева. [br]
## Входные параметры: [br]
##   [param grid]: Array - Двумерная сетка комнат. [br]
##   [param leftover]: Array
##       Список рёбер, которые были отброшены Kruskal, потому что
##       их добавление соединяло бы комнаты, уже находящиеся в одной компоненте.
##       Каждый элемент имеет вид:
##           [pos1, pos2, distance] [br]
##   [param claimed]: Dictionary
##       Общий реестр занятых ресурсов коридоров:
##       угловые клетки и элементарные сегменты прямых путей.
##       Используется для предотвращения пересечений и повторного использования пути. [br]
## Возвращаемое значение: void [br]
## Функция изменяет grid непосредственно через _apply_edge().
func _adding_cycle_edges(grid: Array, leftover: Array, claimed: Dictionary) -> void:
	# Перебираем все рёбра, которые Kruskal не использовал.
	for edge in leftover:
		# Генерируем случайное число от 0.0 до 1.0.
		# Если случайное значение оказалось больше либо равно loop_chance, текущее ребро НЕ добавляется.
		# Следовательно, вероятность прохождения этого условия зависит от loop_chance.
		if rng_rand.randf() >= loop_chance:
			continue

		# Определяем разницу координат концов ребра.
		var diff = edge[1] - edge[0]
		# По этим координатам определяем, будет ли путь прямым или диагональным.
		var is_diagonal = diff.x != 0 and diff.y != 0

		# Повторно проверяем физическую проходимость пути.
		# Это необходимо, потому что за время обработки leftover уже могли появиться
		# занятые сегменты/углы от других дополнительных рёбер.
		var path_clear = _diagonal_path_clear(grid, claimed, edge[0], edge[1]) if is_diagonal \
			else _straight_path_clear(grid, claimed, edge[0], edge[1])
		if not path_clear:
			continue

		# Добавляем дополнительное соединение между комнатами.
		# Поскольку это ребро уже было в leftover, его комнаты уже находились
		# в одной компоненте. Поэтому это соединение создаёт цикл.
		_apply_edge(grid, edge[0], edge[1])

		# После создания дополнительного пути отмечаем занятые ресурсы,
		# чтобы следующие leftover-рёбра не пересекли этот путь.
		if is_diagonal:
			_mark_diagonal_path(claimed, edge[0], edge[1])
		else:
			_mark_straight_run(claimed, edge[0], edge[1])


# БЛОК ФУНКЦИЙ ДЛЯ ИЗБАВЛЕНИЯ ОТ ИЗОЛИРОВАННЫХ КОМНАТ

## Пытается соединить все оставшиеся разрозненные компоненты комнат.
##
## grid: двумерная сетка комнат, используемая для проверки и создания коридоров.
## parent: Dictionary DSU, хранящий структуру связности всех комнат.
## all_cells: массив всех существующих комнат.
## claimed: Dictionary с угловыми клетками и сегментами коридоров,
##          уже занятыми существующими путями.
##
## Функция работает до тех пор, пока все комнаты не окажутся в одной
## компоненте связности. На каждой итерации она ищет ближайшую допустимую
## пару комнат из разных компонентов и соединяет их.
func _connect_remaining_components(grid: Array, parent: Dictionary, all_cells: Array, claimed: Dictionary) -> void:
	while true:
		# Каждый раз заново собираем компоненты через DSU.
		# Ключ = корень компоненты, значение = все комнаты этой компоненты.
		var components: Dictionary = {}
		for cell in all_cells:
			var root = _uf_find(parent, cell["position"])
			if not components.has(root):
				components[root] = []
			components[root].append(cell)

		# Если осталась одна компонента, все комнаты уже связаны.
		if components.size() <= 1:
			print("Все компоненты успешно связаны")
			return

		# Получаем корни всех существующих компонентов.
		var roots = components.keys()

		# Здесь будет храниться самая короткая допустимая связь,
		# найденная среди всех пар разных компонентов.
		var best_pair = null
		var best_is_diagonal = false
		var best_dist = INF

		# Перебираем пары компонентов. range(a + 1, ...) не даёт проверять одну и ту же пару дважды:
		#   A-B проверяется, а B-A уже не проверяется.
		for a in range(roots.size()):
			for b in range(a + 1, roots.size()):
				# Внутри каждой пары компонентов перебираем все комнаты.
				# Таким образом проверяется каждая возможная связь между комнатами двух разных компонентов.
				for cell_a in components[roots[a]]:
					for cell_b in components[roots[b]]:
						var pos_a = cell_a["position"]
						var pos_b = cell_b["position"]
						var diff = pos_b - pos_a
						var is_diagonal = diff.x != 0 and diff.y != 0

						# Проверяем, можно ли физически провести коридор данного типа.
						var path_clear = _diagonal_path_clear(grid, claimed, pos_a, pos_b) if is_diagonal \
							else _straight_path_clear(grid, claimed, pos_a, pos_b)
						if not path_clear:
							continue

						# Считаем расстояние между двумя комнатами.
						# Из всех допустимых вариантов будет выбран самый короткий.
						var dist = pos_a.distance_to(pos_b)

						if dist < best_dist:
							best_dist = dist
							best_pair = [pos_a, pos_b]
							best_is_diagonal = is_diagonal

		# Если подходящей пары не нашлось, соединить оставшиеся компоненты с текущими правилами невозможно.
		if best_pair == null:
			_fully_connected = false
			print("FloorGenerator: не удалось связать все комнаты (%d групп). Сид: %s" % [components.size(), rng_rand.seed])
			return

		# Добавляем найденное лучшее соединение в граф.
		_apply_edge(grid, best_pair[0], best_pair[1])

		# Помечаем физические ресурсы выбранного пути как занятые.
		# Благодаря этому следующая итерация не сможет проложить новый путь
		# через тот же угол или сегмент.
		if best_is_diagonal:
			_mark_diagonal_path(claimed, best_pair[0], best_pair[1])
		else:
			_mark_straight_run(claimed, best_pair[0], best_pair[1])

		# После физического создания связи необходимо обновить DSU:
		# две ранее разные компоненты теперь становятся одной.
		var root1 = _uf_find(parent, best_pair[0])
		var root2 = _uf_find(parent, best_pair[1])
		parent[root1] = root2
