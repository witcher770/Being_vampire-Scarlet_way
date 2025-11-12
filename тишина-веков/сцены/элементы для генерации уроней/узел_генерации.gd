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

func _ready():
	rng_seed.seed = 12345  # фиксированный сид для воспроизводимости
	#rng.randomize() # или для случайного сида каждый раз
	
	var empty_grid = create_grid(size_level)
	grid_with_rooms = gen_pos_rooms(empty_grid.duplicate())
	var grid_with_connections = create_tree_connectoins(grid_with_rooms)
	
	
	print_grid(grid_with_connections, "connections")
	
	
	var a = get_neightbours(grid_with_rooms, Vector2(0, 2))
	#print(a)
	

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



func connect_rooms(grid: Array) -> Array:
	
	return[-1]


func create_tree_connectoins(grid: Array) -> Array: 
	var in_tree = []  # комнаты уже в дереве
	var edges = []    # возможные соединения для добавления
	var first_room: bool = false
	
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
					var connection: Array = [cell["position"], near_room["position"]]
					edges.append(connection)
				
				# если все соседи уже в дереве пропускаем комнату
				if edges.size() == 0:
					continue 
				# теперь из массива всех связей выберем случайную и сформируем ее
				var num_conct = rng_rand.randi_range(0,edges.size() - 1)  # выбираем случайную связь. генерит включительно, поэтому -1
				
				var pos_room1: Vector2 = edges[num_conct][0]
				var room1 = grid[pos_room1.x][pos_room1.y]
				var pos_room2: Vector2 = edges[num_conct][1]
				var room2 = grid[pos_room2.x][pos_room2.y]
				
				# удаляем из списка связей рассмотренную
				edges.remove_at(num_conct)  # удаляем использованную связь
				
				# записываем им ссылки друг на друга
				room1["connections"].append(pos_room1 - pos_room2) # относительное смещение на вторую комнату
				room2["connections"].append(pos_room2 - pos_room1)
				
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
	
	
	
