extends Node

# Централизованный словарь всех загружаемых ресурсов
const PRELOADS = {
	# Игрок
	"player": preload("res://сцены/игрок/Игрок.tscn"),
	
	# Комнаты
	"start_room": preload("res://сцены/элементы для генерации уроней/комнаты/start_room.tscn"),
	"boss_skilet_lev1": preload("res://сцены/элементы для генерации уроней/boss_skilet_lev1.tscn"),
	
	# Уровни/генераторы
	"generation_node": preload("res://сцены/элементы для генерации уроней/узел_генерации.tscn")
}

@onready var player_container = $PlayerContainer
@onready var level_container = $LevelContainer

var player_instance = null
var current_level = null


func _ready():
	load_player()
	load_start_room()


func load_player():
	if player_instance:
		return
	
	player_instance = PRELOADS.player.instantiate()
	player_container.add_child(player_instance)

	# восстановление здоровья
	player_instance.player_health = GameState.player_health


func load_start_room():
	unload_level()

	current_level = PRELOADS.start_room.instantiate()
	level_container.add_child(current_level)
	
	# подписываемся на сигнал покидания стартовой комнаты
	current_level.leave_start_room.connect(_on_level_finished)

	move_player_to_spawn(current_level)

func _on_level_finished():
	GameState.num_floor = GameState.num_floor + 1
	#print(GameState.num_floor)
	if GameState.num_floor_for_boss == GameState.levels_for_boss:
		load_boss_room()
		return
	# при получении сигнала на вхождение в дверь - переход на следующий уровень
	load_generated_level()

func load_generated_level():
	unload_level()
	GameState._enemies_count = 0
	GameState.num_floor_for_boss = GameState.num_floor_for_boss + 1
	
	current_level = PRELOADS.generation_node.instantiate()
	level_container.add_child(current_level)
	
	current_level.level_finished.connect(_on_level_finished)
	GameState.enemy_power += 0.1
	if GameState.num_floor % 3 == 0:
		GameState.count_rooms += 1
		GameState.enemies_in_room += 1
	
	move_player_to_spawn(current_level)


func load_boss_room():
	unload_level()
	GameState._enemies_count = 1

	current_level = PRELOADS.boss_skilet_lev1.instantiate()
	level_container.add_child(current_level)
	
	current_level.level_finished.connect(_on_level_finished)
	move_player_to_spawn(current_level)
	
	GameState.levels_for_boss += 1
	GameState.num_floor_for_boss = 0
	GameState.num_global_level += 1


func unload_level():
	if current_level:
		print("удаляю - ", current_level)
		current_level.queue_free()
		current_level = null


func move_player_to_spawn(level_scene):
	# ищем узел SpawnPoint в уровне
	var spawn = level_scene.get_node("SpawnPoint")
	if spawn:
		player_instance.global_position = spawn.global_position
