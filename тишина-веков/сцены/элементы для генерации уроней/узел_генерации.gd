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
	#rng.seed = 12345  # фиксированный сид для воспроизводимости
	rng.randomize() # или для случайного сида каждый раз
	
	var empty_grid = create_grid(size_level)
	grid_with_rooms = gen_pos_rooms(empty_grid)
	for i in range(size_level):
		print(grid_with_rooms[i])
	

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
				"position": Vector2(x, y) # просто координаты
			}
		
		# если комната первая, делаем стартовой
		if quantity_pos == size_level ** 2:
			cell_info["room_type"] = "start_room"
		# на место ячейки записываем вектор с координатами этой позиции вместо null
		grid[x][y] = Vector2(x, y)
		
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
