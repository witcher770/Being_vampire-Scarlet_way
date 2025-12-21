extends Node

signal all_enemies_dead

var num_floor: int = -1            # текущий уровень-этаж
var player_health: int = 100      # здоровье игрока
var max_health: int = 100

var size_dungeon = 1
var room_count: int = 3           # базовое количество комнат
var enemy_power: float = 1.0      # множитель силы врагов
var enemies_count: int = 0          # количество врагов на уровне
var levels_for_boss: int = 0

var next_level_type: String = "normal"  # "normal" или "boss"

# координата появления игрока в новом уровне
var spawn_position: Vector2 = Vector2.ZERO


func set_enemies_count(value: int) -> void: # хз нужна ли такая функция
	enemies_count = value

func enemy_died() -> void:
	enemies_count -= 1
	print("Осталось врагов:", enemies_count)

	if enemies_count <= 0:
		all_enemies_dead.emit()
