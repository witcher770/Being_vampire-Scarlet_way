extends Node

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
	
	var player_scene = preload("res://сцены/игрок/Игрок.tscn")
	player_instance = player_scene.instantiate()
	player_container.add_child(player_instance)

	# восстановление здоровья
	player_instance.player_health = GameState.player_health


func load_start_room():
	unload_level()

	var scene = preload("res://сцены/элементы для генерации уроней/комнаты/start_room.tscn")
	current_level = scene.instantiate()
	level_container.add_child(current_level)
	
	# подписываемся на сигнал покидания стартовой комнаты
	current_level.leave_start_room.connect(_on_level_finished)

	move_player_to_spawn(current_level)

func _on_level_finished():
	print(GameState.num_floor)
	if GameState.num_floor == 3:
		load_boss_room()
		return
	# при получении сигнала на вхождение в дверь - переход на следующий уровень
	load_generated_level()

func load_generated_level():
	unload_level()
	GameState.num_floor = GameState.num_floor + 1
	
	var scene = preload("res://сцены/элементы для генерации уроней/узел_генерации.tscn")
	current_level = scene.instantiate()
	level_container.add_child(current_level)
	
	current_level.level_finished.connect(_on_level_finished)
	
	move_player_to_spawn(current_level)


func load_boss_room():
	unload_level()

	var scene = preload("res://сцены/элементы для генерации уроней/boss_room.tscn")
	current_level = scene.instantiate()
	level_container.add_child(current_level)

	move_player_to_spawn(current_level)



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
