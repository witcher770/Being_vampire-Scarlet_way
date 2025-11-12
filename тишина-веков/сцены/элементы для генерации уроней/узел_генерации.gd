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

var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = 12345  # фиксированный сид для воспроизводимости
	#rng.randomize() # или для случайного сида каждый раз
	
	var empty_grid = create_grid(size_level)
	grid_with_rooms = gen_pos_rooms(empty_grid.duplicate())
	
	print_grid(grid_with_rooms)
	
	
	var a = get_neightbours(grid_with_rooms, Vector2(0, 2))
	print(a)
	

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
		var num_pos = rng.randi_range(0, quantity_pos - 1)  # генерируем позицию для комнаты. генерит включительно, поэтому -1
		
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
		
		# если комната первая, делаем стартовой
		if quantity_pos == size_level ** 2:
			cell_info["room_type"] = "start_room"
		
		# на место ячейки записываем словарь с информацией о ней
		grid[x][y] = cell_info
		## на место ячейки записываем вектор с координатами этой позиции вместо null
		#grid[x][y] = Vector2(x, y)
		
		maybe_pos_rooms.remove_at(index)  # удаляем использованную(уже занятую) позицию
		quantity_pos -= 1 # уменьшаем количество доступных мест

		
	return grid


# функция добавления в сетку комнаты
#func append_one_room(coords: Vector2) -> Vector2:
	## проверяем лимит созданных комнат
	#if rooms_now < num_rooms:
		## проверяем переданные координаты на корректность
		#if 0 <= coords.x <= size_level and 0 <= coords.y <= size_level and grid_with_rooms[coords.x][coords.y] == null:
			## информация о ячейке
			#
			#
			#if rooms_now == 0:
				#cell_info["room_type"] = "start_room"
			## добавляем комнату в сетку
			#grid_with_rooms[coords.x][coords.y].append(cell_info)
			#rooms_now += 1
			#return coords # возвращаем координаты где создали
		#
	#return Vector2(-1, -1) # возвращаем если ничего не создали. в отрицательной четверти работать не будем


func connect_rooms(grid: Array) -> Array:
	
	return[-1]


func create_tree_connectoins(grid: Array) -> Array: 
	var in_tree = []  # комнаты уже в дереве
	var edges = []    # возможные соединения для добавления
	
	
	return [-1]


func get_neightbours(grid: Array, coords: Vector2) -> Array: # возвращает массив соседей
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
					#print(cell)
					if cell:
						edges.append(Vector2(move_x, move_y))
						continue
			maybe_pos_edges[i][j] = 0
	
	#print("возможные позиции соседей")
	#for d in range(3):
		#print(maybe_pos_edges[d])
	
	if edges.size() == 0: # если на соседних клетках соседей нет
		pass # тут должен быть рекурсивный вызов этой же функции с увеличенными параметрами глубины. Требует доработки
		var dorobotka = 0
	
	return edges
	
	
	
