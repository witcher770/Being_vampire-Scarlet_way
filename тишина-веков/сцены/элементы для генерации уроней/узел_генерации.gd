extends Node2D

##Массив хранящий прелоады комнат ??
#var room_array =[]
#
##Сам генерируемый лабиринт
#var labirint_array ={}
#
##размер лабиринта 5x5
#@export var labirint_size = 5
##Количество комнат
#@export var room_count = 5
#
##Переменная потребуется, для увеличение максимально сгенерированного числа
##Если вдруг мы не смогли расставить все комнаты, при первом цикле
#var random_max = 1

# задаем размер сетки и количество комнат
@export var size_level = 3
@export var num_rooms = 3

var rooms_now = 0
var grid_with_rooms = []

var rng_rand = RandomNumberGenerator.new()
var rng_seed = RandomNumberGenerator.new()

const SIZE_TILE: int = 16
const SIZE_CELL: int = 25
const SIZE_ROOM: int = 15
const SIZE_ZONE: Vector2 = Vector2(SIZE_TILE * SIZE_CELL, SIZE_TILE * SIZE_CELL)  # размер зоны в пикселях

func _ready():
	rng_seed.seed = 12345  # фиксированный сид для воспроизводимости
	#rng.randomize() # или для случайного сида каждый раз
	
	var empty_grid = create_grid(size_level)
	grid_with_rooms = gen_pos_rooms(empty_grid.duplicate())
	var grid_with_connections = create_tree_connectoins(grid_with_rooms)
	calculate_exits(grid_with_connections)
	
	print_grid(grid_with_connections, "connections")
	print()
	instantiate_rooms(grid_with_connections)
	instantiate_corridors(grid_with_connections)
	
	
	#var a = get_neightbours(grid_with_rooms, Vector2(0, 2))
	#print(a)
	#var room_scene = preload("res://сцены/элементы для генерации уроней/комнаты/комната_15_15_1.tscn")
	#var room_instance = room_scene.instantiate()
	#room_instance.position = Vector2(0, 0)
	#add_child(room_instance)


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
	
	for i in range(num_rooms):
		var num_pos = rng_seed.randi_range(0, quantity_pos - 1)  # генерируем позицию для комнаты. генерит включительно, поэтому -1
		print("Текущее зерно: ", rng_rand.seed)
		
		# удаляем из списка возможных позиций комнат ту, куда сейчас ставим
		var index = maybe_pos_rooms.find(num_pos)  # находим индекс элемента
		var pos = maybe_pos_rooms[index] - 1 # получаем номер места для комнаты в сетке. -1 чтобы получить не номер, а индекс 
		
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
		## на место ячейки записываем вектор с координатами этой позиции вместо null
		#grid[x][y] = Vector2(x, y)
		
		maybe_pos_rooms.remove_at(index)  # удаляем использованную(уже занятую) позицию
		quantity_pos -= 1 # уменьшаем количество доступных мест

		
	return grid


func create_tree_connectoins(grid: Array) -> Array: 
	var in_tree = []  # комнаты уже в дереве
	var edges = []    # возможные соединения для добавления
	var first_room: bool = true
	
	for i in range(size_level):
		for j in range(size_level):
			var cell = grid[i][j]
			if cell:
				if cell in in_tree:
					#continue # если эту комнату уже рассмотре
					pass
				
				# если комната первая, делаем стартовой
				if first_room:
					cell["room_type"] = "start_room"
					
					# попытка добавить игрока
					print("ставим игрока")
					var player = preload("res://сцены/игрок/Игрок.tscn")
					var player_inst = player.instantiate()
					print(cell["position"])
					player_inst.position = grid_to_world(cell["position"]) + Vector2(200, 200)
					add_child(player_inst)
					
					in_tree.append(cell) # добавляем первую ячейку в дерево
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
				
				# не уверен нужно ли это так как при присваивании ссылки но на всякий случай
				# перезаписываем в сетке на комнаты с добавленными связями
				grid[pos_room1.x][pos_room1.y] = room1
				grid[pos_room2.x][pos_room2.y] = room2
				
				
				# добавляем соединенную комнату в дерево
				if room1 not in in_tree:
					in_tree.append(room1)
				if room2 not in in_tree:
					in_tree.append(room2)
	return grid


func get_neightbours(grid: Array, coords: Vector2) -> Array: # возвращает массив соседей - комнат
	var edges = []
	var size_matrix = 3 # изнчально матрица соседей 3 на 3, с переданным элементом в центре
	var maybe_pos_edges = create_grid(size_matrix) # массив возможных позиций(не выходящих за сетку) для отладки
	var depth = 0 # глубина поиска соседей ,кол-во просматриваемых окружностей
	var depth_for_cicle = 1 # нужна чтобы нормализовывать i и j, делая из индексов относит. смещение
	
	for i in range(size_matrix + depth * 2): # изнчально матрица соседей 3 на 3, и каждая следующая откружность на 2 больше
		for j in range(size_matrix + depth * 2):
			if i == j: # пропускаем ячейку в которой находится сама проверяемая комната
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
				var pos_for_create = Vector2(global_pos_cell.x + SIZE_ZONE.x / 2, global_pos_cell.y + SIZE_ZONE.y / 2) # координаты центра ячейки
				# Выбираем префаб комнаты по количеству выходов
				#var room_scene = choose_room_prefab(cell.exits)
				var room_scene = preload("res://сцены/элементы для генерации уроней/комнаты/комната_15_15_1.tscn")
				cell["room_instance"] = room_scene.instantiate()
				cell["room_instance"].position = pos_for_create
				add_child(cell["room_instance"])
	return grid


# центр коридора поместить в сам поворот и размещать в центре ячейки
# коридор центр по центру коридора также, а размещать на стыке ячеек
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
					var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_в_комнату_сверху.tscn")
					var exit_inst = exit.instantiate()
					exit_inst.position = pos_room - offset_room_y
					add_child(exit_inst)
					if connection.y == 0: # прямой вверх - логика урощена при опоре на варианты получения этого выхода из функции расчета выходов
						# меняем знаки, тк связь на эту комнату, от второй комнаты в паре будет с противоположными знаками
						var corridor_up = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_вертикальный_8.tscn")
						var corridor_up_inst = corridor_up.instantiate()
						corridor_up_inst.position = pos_room - offset_cell_y
						add_child(corridor_up_inst)
					else: # буква г
						# меняем знаки, тк связь на эту комнату, от второй комнаты в паре будет с противоположными знаками
						instantiate_g_corridor(pos_room)
				# обычные проверки + проверяем что текущая связь к комнате справа
				elif cell["exits"]["east"] and not exits_chek[1] and (connection.x == 0 and connection.y > 0):
					exits_chek[1] = true
					# добавляем к комнате выход
					var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_в_комнату_справа.tscn")
					var exit_inst = exit.instantiate()
					exit_inst.position = pos_room + offset_room_x
					add_child(exit_inst)
					# добавляем сам коридор. на восток может идти только прямой коридор
					var corridor_right = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_горизонтальный_8.tscn")
					var corridor_right_inst = corridor_right.instantiate()
					corridor_right_inst.position = pos_room + offset_cell_x
					add_child(corridor_right_inst)
				# обычные проверки + проверяем что текущая связь к комнате внизу или внизу справа
				elif cell["exits"]["south"] and not exits_chek[2] and (connection.x > 0 and (connection.y == 0 or connection.y > 0)):
					exits_chek[2] = true
					# добавляем к комнате выход
					var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_в_комнату_снизу.tscn")
					var exit_inst = exit.instantiate()
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
					var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_в_комнату_справа.tscn")
					var exit_inst = exit.instantiate()
					exit_inst.scale.x = -1
					exit_inst.position = pos_room - offset_room_x
					add_child(exit_inst)
	
	return grid


func instantiate_g_corridor(pos_room: Vector2):
	# загружаем
	var corridor_up = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_вертикальный_8.tscn")
	var corridor_right = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_горизонтальный_8.tscn")
	var corridor_g = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_г_10_10.tscn")
	# создаем
	var corridor_up_inst = corridor_up.instantiate()
	var corridor_right_inst = corridor_right.instantiate()
	var corridor_g_inst = corridor_g.instantiate()
	# размещаем
	corridor_up_inst.position = pos_room - Vector2(0, SIZE_ZONE.y / 2)
	corridor_g_inst.position = pos_room - Vector2(0, SIZE_ZONE.y)
	corridor_right_inst.position = pos_room - Vector2(0, SIZE_ZONE.y) + Vector2(SIZE_ZONE.x / 2, 0)
	# добавляем
	add_child(corridor_up_inst)
	add_child(corridor_g_inst)
	add_child(corridor_right_inst)


func instantiate_invert_g_corridor(pos_room: Vector2):
	# загружаем
	var corridor_up = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_вертикальный_8.tscn")
	var corridor_right = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_горизонтальный_8.tscn")
	var corridor_g = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/коридор_перевернутая_г_10_10.tscn")
	# создаем
	var corridor_up_inst = corridor_up.instantiate()
	var corridor_right_inst = corridor_right.instantiate()
	var corridor_g_inst = corridor_g.instantiate()
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
		var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_сверху_стена.tscn")
		var exit_inst = exit.instantiate()
		exit_inst.position = pos_room - Vector2(0, (SIZE_ROOM * SIZE_TILE) / 2)
		add_child(exit_inst)
	if not cell["exits"]["east"]:
		var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_справа_стена.tscn")
		var exit_inst = exit.instantiate()
		exit_inst.position = pos_room + Vector2((SIZE_ROOM * SIZE_TILE) / 2, 0)
		add_child(exit_inst)
	if not cell["exits"]["south"]:
		var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_снизу_стена.tscn")
		var exit_inst = exit.instantiate()
		exit_inst.position = pos_room + Vector2(0, (SIZE_ROOM * SIZE_TILE) / 2)
		add_child(exit_inst)
	if not cell["exits"]["west"]:
		var exit = preload("res://сцены/элементы для генерации уроней/фрагменты коридоров/вход_справа_стена.tscn")
		var exit_inst = exit.instantiate()
		exit_inst.scale.x = -1
		exit_inst.position = pos_room - Vector2((SIZE_ROOM * SIZE_TILE) / 2, 0)
		add_child(exit_inst)

# процедурная генерация завершена
