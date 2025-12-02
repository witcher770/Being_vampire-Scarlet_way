extends Node

var num_floor: int = 1            # текущий уровень-этаж
var player_health: int = 100      # здоровье игрока
var max_health: int = 100

var room_count: int = 5           # базовое количество комнат
var enemy_power: float = 1.0      # множитель силы врагов

var next_level_type: String = "normal"  # "normal" или "boss"

# координата появления игрока в новом уровне
var spawn_position: Vector2 = Vector2.ZERO
