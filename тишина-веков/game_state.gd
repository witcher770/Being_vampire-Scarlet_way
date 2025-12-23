extends Node

signal all_enemies_dead

var num_floor: int = -1            # текущий уровень-этаж
var player_health: int = 100      # здоровье игрока
var max_health: int = 100

var size_dungeon = 2               # размер квадратной матрицы
var count_rooms: int = 2           # базовое количество комнат
var enemy_power: float = 1         # множитель силы врагов   + 0.1 каждый уровень
var enemies_in_room: int = 2
var levels_for_boss: int = 10       # каждые сколько комнат будет запускаться комната с боссом
var num_floor_for_boss: int = 0    # количество пройденных комнат с прошлого босса
var num_global_level: int = 1      # глобальный этаж для выбора комнаты босса и ресурсов генерации

var _enemies_count: int = 0         # количество врагов на уровне


var next_level_type: String = "normal"  # "normal" или "boss"

# координата появления игрока в новом уровне
var spawn_position: Vector2 = Vector2.ZERO


func set_enemies_count(value: int) -> void: # хз нужна ли такая функция
	_enemies_count = value

func enemy_died() -> void:
	_enemies_count -= 1
	print("Осталось врагов:", _enemies_count)

	if _enemies_count <= 0:
		all_enemies_dead.emit()
