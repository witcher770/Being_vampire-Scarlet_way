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
#var is_knockback := false
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


enum PlayerState {
	IDLE,
	MOVE,
	ATTACK,
	KNOCKBACK,
	DEAD
}

var state: PlayerState = PlayerState.IDLE

func _physics_process(delta):
	match state:
		PlayerState.IDLE:
			#print("перешел в состояние idle")
			process_idle(delta)
		PlayerState.MOVE:
			#print("перешел в состояние move")
			process_move(delta)
		PlayerState.ATTACK:
			#print("перешел в состояние attack")
			#state_attack(delta)
			pass
		PlayerState.KNOCKBACK:
			#print("перешел в состояние knockback")
			process_knockback(delta)
			#pass


@warning_ignore("unused_parameter")
func process_idle(delta):
	if Input.is_action_just_pressed("атака"):
		enter_attack()
		return
	
	update_idle_animation()
	var input_vector = get_input_vector()
	if input_vector != Vector2.ZERO:
		state = PlayerState.MOVE


func update_idle_animation():
	if flag_last_direction == 0:
		# Нет движения - проигрываем анимацию покоя
		animPlayer.play('покой_перед_папин')
	elif flag_last_direction == 1:
		animPlayer.play('покой_с_боку_папин')
		# Разворот спрайта в направлении движения
		#if not flag_move_right:
			#sprite.scale.x *= -1  # Отражаем спрайт по горизонтали
	elif flag_last_direction == 2:
		animPlayer.play('покой_спина_папин')


@warning_ignore("unused_parameter")
func process_move(delta):
	# Внутри _state_idle и _state_move добавь:
	if Input.is_action_just_pressed("атака"):
		enter_attack()
		return
	
	var input_vector = get_input_vector()

	if input_vector == Vector2.ZERO:
		state = PlayerState.IDLE
		return

	facing_direction = input_vector
	velocity = input_vector * speed # Применяем движение
	# Смещаем область атаки в направлении движения
	attack_area.position = facing_direction * 15
	move_and_slide() # Встроенная функция Godot для перемещения с коллизиями
	update_move_animation()


func get_input_vector() -> Vector2:
	# Получаем вектор ввода от игрока (нормализованный - длина всегда 1)
	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),  # Горизонталь: -1..1
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")      # Вертикаль: -1..1
	).normalized()  # Нормализуем чтобы диагональное движение не было быстрее
	return input_vector

var flag_last_direction = 0
func update_move_animation():
# ВЫБОР АНИМАЦИИ В ЗАВИСИМОСТИ ОТ НАПРАВЛЕНИЯ:
	if facing_direction.x != 0:
		flag_last_direction = 1
		# Горизонтальное движение - анимация "вид сбоку"
		animPlayer.play("бег_с_боку_папин")
		# Разворот спрайта в направлении движения
		if sign(sprite.scale.x) != sign(facing_direction.x):
			#flag_move_right = false
			sprite.scale.x *= -1  # Отражаем спрайт по горизонтали
		#else:
			#flag_move_right = true
	elif facing_direction.y > 0:
		flag_last_direction = 0
		# Движение вниз - анимация "вид спереди"
		animPlayer.play("бег_перед_папин")
	elif facing_direction.y < 0:
		flag_last_direction = 2
		# Движение вверх - анимация "вид сзади"
		animPlayer.play("бег_спина_папин")


func enter_attack():
	state = PlayerState.ATTACK   # ← ВОТ ЭТО КЛЮЧЕВО
	print("перешел в состояние attack")
	velocity = Vector2.ZERO

	play_attack_animation()
	print("запустил анимацию атаки")

	_attack_sequence()


func _attack_sequence() -> void:
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = true

	await animPlayer.animation_finished
	print("дождался конца анимации атаки")

	attack_area.monitoring = false
	state = PlayerState.IDLE
	print("меняю состояние на idle")


func play_attack_animation():
	if abs(facing_direction.x) > abs(facing_direction.y):
		animPlayer.play("атака_с_боку")
	elif facing_direction.y > 0:
		animPlayer.play("атака_перед")
	else:
		animPlayer.play("атака_спина")


@warning_ignore("unused_parameter")
func process_knockback(delta):
	update_idle_animation()
	move_and_slide()


func enter_knockback(from_position: Vector2):
	state = PlayerState.KNOCKBACK
	print("перешел в состояние knockback")
	#if state == PlayerState.DEAD:
		#return

	var direction = (global_position - from_position).normalized()
	# применяем начальный импульс
	velocity = direction * knockback_force
	
	# создаём плавное затухание (через tween)
	var tween = create_tween()
	#tween.tween_property(self, "velocity", Vector2.ZERO, knockback_duration)
	# это первоначальная версия
	tween.tween_property(self, "velocity", Vector2.ZERO, knockback_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	state = PlayerState.IDLE







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
		take_damage(damage)
		#apply_knockback(enemy_pos)
		enter_knockback(enemy_pos)


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
