extends CharacterBody2D

# другие полезные декораторы
#@export_category("Player Stats")  # Более крупная категория (жирный шрифт)
#@export_subgroup("Weapon Settings")  # Подгруппа внутри группы
#@export_range(1, 100, 1) var health: int  # Ограничение диапазона
#@export_flags("Fire", "Water", "Earth", "Air") var elements: int  # Флаги

# === ССЫЛКИ НА ЭЛЕМЕНТЫ ===
@onready var animPlayer = $AnimationPlayer  # Ссылка на нод анимаций
@onready var sprite = $Sprite2D  # Ссылка на спрайт персонажа
@onready var health_bar = $HealthBar  # Ссылка на полоску здоровья
@onready var attack_area = $ОбластьАтаки  # Ссылка на Area2D для атаки
@onready var damage_area = $ОбластьУронаКасанием

# === СИГНАЛЫ ===
signal took_damage(position, amount, is_crit) # сигнал о получении урона 
signal player_died # сигнал о смерти игрока


# === НАСТРОЙКИ ПЕРСОНАЖА ===
var facing_direction := Vector2.RIGHT  # Текущее направление взгляда (для атаки и анимации)
var is_invincible := false
var is_knockback := false
var knockback_velocity := Vector2.ZERO

@export_group("Combat Settings", "combat_")
@export var combat_attack_damage_min := 1
@export var combat_attack_damage_max := 3  
@export var combat_crit_chance := 0.3
@export var combat_invincibility_time := 1.0

@export_group("Movement Settings") 
@export var speed := 150.0 # Скорость перемещения персонажа (пикселей в секунду)

@export_group("Health Settings")
@export var player_health := 100  # Текущее здоровье игрока (настраивается в редакторе)
@export var player_max_health := 100  # Максимальное здоровье игрока

@export_group("Knockback Settings")
@export var knockback_force := 200.0  # Сила отталкивания
@export var knockback_duration := 0.4  # Длительность отталкивания

func _ready():
	randomize()  # Инициализация генератора случайных чисел для критических ударов
	add_to_group("игрок") # я так то добавил группу в инспекторе но пусть и тут будет

	# Настройка области атаки
	attack_area.monitoring = false  # Отключаем коллизии атаки до момента удара
	attack_area.body_entered.connect(_on_attack_hit)  # Подключаем сигнал попадания
	damage_area.body_entered.connect(_on_damage_area_touch_body_entered) # Подключаем сигнал урона от касания
	
	# Инициализация системы здоровья
	health_bar.health = player_health
	health_bar.max_health = player_max_health
	
	took_damage.connect(DamageNumbersManager.show_damage)


# === СИСТЕМА ЗДОРОВЬЯ И УРОНА ===
func take_damage(amount: int):
	"""
	Вызывается когда игрок получает урон
	amount - количество получаемого урона
	"""
	var is_dead = health_bar.take_damage(amount)
	took_damage.emit(calculate_damage_position(), amount, false, true)
	# Проверяем смерть
	if is_dead:
		die()
	else:
		# Запускаем неуязвимость если выжил
		start_invincibility()
		
		# Эффекты только если игрок выжил
		# screen_shake()  # Тряска экрана
		# spawn_blood_particles()  # Частицы крови
		pass
	
	# МЕСТО ДЛЯ ДОБАВЛЕНИЯ ЭФФЕКТОВ:
	# - Мигание спрайта (modulate)
	# - Тряска камеры
	# - Звук получения урона
	# - Эффект крови/частиц



func _on_damage_area_touch_body_entered(body):
	# Проверяем: это враг И игрок не неуязвим
	if body.is_in_group("враги") and not is_invincible:
		var enemy_pos = body.global_position
		var damage = body.deal_contact_damage()
		take_damage(damage) # Пока фиксированный урон 1
		apply_knockback(enemy_pos)



func calculate_damage_position() -> Vector2:
	# Надежное вычисление позиции
	if sprite:
		# половина размера спрайта и на 20 повыше
		return global_position - Vector2(0, sprite.texture.get_height() * sprite.scale.y * 0.5 + 20) 
	else:
		return global_position - Vector2(0, 50)  # fallback


func start_invincibility():
	is_invincible = true
	#print("Неуязвимость активирована")
	
	# Простой эффект мигания (позже заменишь на анимацию)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.5, 0.5, 0.7), 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.set_loops(5)  # 5 миганий
	
	# Таймер окончания неуязвимости
	await get_tree().create_timer(combat_invincibility_time).timeout
	is_invincible = false


func die():
	print("Игрок умер!")
	# Останавливаем логику ДО удаления
	#set_physics_process(false)
	#set_process_input(false)
	#velocity = Vector2.ZERO
	
	player_died.emit()
	print("отправил сигнал, я умер")
	queue_free()

# === СИСТЕМА ПЕРЕМЕЩЕНИЯ ===
func _physics_process(delta):
	if is_knockback:
		animPlayer.play('покой') # тут надо переключать на статичные позы чтобы не было добегивания
		move_and_slide()
		return
	
	# Получаем вектор ввода от игрока (нормализованный - длина всегда 1)
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),  # Горизонталь: -1..1
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")      # Вертикаль: -1..1
	).normalized()  # Нормализуем чтобы диагональное движение не было быстрее
	
	# ОБРАБОТКА ДВИЖЕНИЯ И АНИМАЦИЙ
	if input_vector != Vector2.ZERO:
		# Есть движение - обновляем направление и анимации
		facing_direction = input_vector
		
		# ВЫБОР АНИМАЦИИ В ЗАВИСИМОСТИ ОТ НАПРАВЛЕНИЯ:
		if input_vector.x != 0:
			# Горизонтальное движение - анимация "вид сбоку"
			animPlayer.play("бег_с_боку")
			# Разворот спрайта в направлении движения
			if sign(sprite.scale.x) != sign(input_vector.x):
				sprite.scale.x *= -1  # Отражаем спрайт по горизонтали

		elif input_vector.y > 0:
			# Движение вниз - анимация "вид спереди"
			animPlayer.play("бег_перед")
		elif input_vector.y < 0:
			# Движение вверх - анимация "вид сзади"
			animPlayer.play("бег_спина")
		
		# Смещаем область атаки в направлении движения
		attack_area.position = facing_direction * 15
	
	else:
		# Нет движения - проигрываем анимацию покоя
		animPlayer.play('покой')

	# Применяем движение
	velocity = input_vector * speed
	move_and_slide()  # Встроенная функция Godot для перемещения с коллизиями


func apply_knockback(from_position: Vector2):
	if is_knockback:
		return
	#print("Отталкивание от:", from_position)

	is_knockback = true
	
	var direction = (global_position - from_position).normalized()
	var knockback = direction * knockback_force
	
	# применяем начальный импульс
	velocity = knockback
	
	# создаём плавное затухание (через tween)
	var tween = create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, knockback_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	is_knockback = false


# === СИСТЕМА АТАКИ ===
func _input(event):
	"""
	Обработка нажатий клавиш (вызывается при каждом вводе)
	"""
	if Input.is_action_just_pressed("атака"):
		# Активируем область атаки на короткое время
		attack_area.monitoring = true
		
		# Таймер для автоматического отключения области атаки
		await get_tree().create_timer(0.1).timeout
		attack_area.monitoring = false
		
		# МЕСТО ДЛЯ ДОБАВЛЕНИЯ:
		# - Анимация атаки
		# - Звук атаки
		# - Эффекты на оружии

# === ОБРАБОТКА ПОПАДАНИЙ АТАКИ ===
func _on_attack_hit(body):
	"""
	Вызывается когда атака попадает в тело (body)
	body - объект который вошел в область атаки (Area2D)
	"""
	if body.is_in_group("враги"):
		# Генерируем случайный урон от 1 до 3
		var damage = randi_range(combat_attack_damage_min, combat_attack_damage_max)
		var is_crit = randf() < combat_crit_chance  # Шанс крита
		
		if is_crit:
			damage *= 2  # Крит удваивает урон
		
		print("число урона: ", damage," значение крита: ", is_crit)
		
		# Наносим урон врагу (вызываем его метод take_damage)
		body.take_damage(damage, is_crit)
		
		# МЕСТО ДЛЯ ДОБАВЛЕНИЯ:
		# - Эффекты попадания
		# - Отталкивание врага
		# - Звук попадания
