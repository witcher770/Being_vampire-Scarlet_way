extends Node2D

@onready var player = $Игрок  # Ссылка игрока


func _ready():
	player.player_died.connect(_on_player_died)

func _on_player_died():
	# Создаем нового игрока
	print("получил сигнал, создаю игрока")
	var new_player = preload("res://сцены/игрок/Игрок.tscn").instantiate()
	add_child(new_player)
	new_player.position = Vector2(100, 100)  # Позиция возрождения
	
	new_player.player_died.connect(_on_player_died)
