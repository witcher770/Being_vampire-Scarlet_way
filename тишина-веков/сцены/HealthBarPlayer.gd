extends TextureProgressBar

@export var health := 100
@export var max_health := 100

func _ready():
	if health > max_health:
		max_health = health
	max_value = max_health
	value = health

func take_damage(amount: int):
	health -= amount
	health = max(0, health)  # Чтобы не ушло в минус
	value = health
	print("У игрока осталось HP: ", health)
	
	if health <= 0:
		die()

func heal(amount: int): # типо функция для хила
	health += amount
	health = min(health, max_health)  # Не больше максимума
	value = health
	
# Добавь в скрипт HealthBar для перманентных улучшений
func increase_max_health(amount: int):
	max_health += amount
	health += amount  # И лечим на эту же величину
	max_value = max_health
	value = health

func die():
	print("Игрок умер!")
	# Тут логика смерти игрока - перезагрузка уровня и т.д.
	get_tree().reload_current_scene()  # Например, перезагрузка
