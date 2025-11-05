extends CharacterBody2D

@onready var health_bar = $HealthBar
@export var health := 3  # можно задавать в редакторе
@export var max_health := 3

func _ready():
	if health > max_health:
		max_health = health
	health_bar.max_value = max_health
	health_bar.value = health


func take_damage(amount := 1, is_crit = false):
	#print("значение крита в take_damage: ", is_crit)

	health -= amount
	health_bar.value = health  # обновляем полоску
	show_damage_number(amount, is_crit)
	print("Осталось HP: ", health)
	if health <= 0:
		die()


func die():
	queue_free()
	
	
@onready var sprite = $Sprite2D  # если он есть
func show_damage_number(amount, is_crit = false):
	#print("значение крита в show_damage_number: ", is_crit)
	var dmg_number = preload("res://сцены/интерфейс/Колличество повреждений.tscn").instantiate()	

	var offset_y = sprite.texture.get_height() * sprite.scale.y * 0.5 + 20
	dmg_number.position = global_position - Vector2(20, offset_y) # поправить координату Х потом
	
	var damage_numbers_node = get_node("/root/сцена боя/HUD/DamageNumbers")
	damage_numbers_node.add_child(dmg_number)
	dmg_number.get_node("Label").show_damage(amount, is_crit)

	#print("сейчас моя позиция", dmg_number.position, "  мой глобальный родитель:", dmg_number.get_parent().name)
	#print('--------------------')




	
	
