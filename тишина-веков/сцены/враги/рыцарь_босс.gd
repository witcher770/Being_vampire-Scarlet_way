extends "res://сцены/враги/враг.gd"

#@onready var animSkelet = $AnimationPlayer  # Ссылка на нод анимаций
@onready var animBossSprite = $AnimatedSprite2D  # Ссылка на нод анимаций
#@onready var sprite1 = $Sprite2D  # Ссылка на спрайт персонажа

enum State {
	IDLE, # ожидание, пока игрок не войдёт в радиус агро
	CHASE, # преследование игрока
	ATTACK_WINDUP, # подготовка к атаке (телеграф - визульный сигнал)
	ATTACK, # удар
	RECOVER, # короткая «перезарядка» после удара
	REPOSITION, # перемещение для удержания оптимальной дистанции (отступление)
	BLOCK,
	DEAD
}

var state : State = State.IDLE

@export var aggro_range = 300.0 # дистанция на которой босс тебя замечает
@export var attack_range = 35.0 # дистанция на которой босс атакует
@export var windup_time = 0.4 # время на подготовку атаки. типо чтобы игрок успел увернуться
@export var recover_time = 1.5 # как часто атакует в секундах
@export var reposition_speed = 180.0 # скорость отступления
@export var optimal_range = 100.0 # дистанция переключения с отступления на нападение

var _stuck_timer = 0.0 # сколько уже не двигаемся
var _last_position = Vector2.ZERO
@export var stuck_time := 0.5 # сколько нужно не двигаться, чтобы встать в блок
@export var stuck_distance_threshold = 2.0 # бри перемещении меньше чем на это число, это не будет считаться движением

@export var block_enter_distance = 45.0
@export var block_exit_distance = 60.0


#func _ready():
	#super._ready() # вызываем родительский ready


func _physics_process(delta):
	match state:
		State.IDLE:
			print("вошел в состояние idle")
			state_idle(delta)

		State.CHASE:
			state_chase(delta)
			

		State.ATTACK_WINDUP:
			state_attack_windup(delta)

		State.ATTACK:
			state_attack(delta)

		State.RECOVER:
			state_recover(delta)

		State.REPOSITION:
			state_reposition(delta)
			
		State.BLOCK:
			state_block(delta)
			
	#print("вошел в состояние - ")
	move_and_slide()


func state_idle(delta): # работает
	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return
	
	update_idle_animation()

	if global_position.distance_to(player.global_position) <= aggro_range:
		print("вошел в состояние chase")
		state = State.CHASE



func update_idle_animation():
	animBossSprite.play("покой")

	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return

	var dir_x = player.global_position.x - global_position.x

	if dir_x != 0:
		animBossSprite.scale.x = sign(dir_x)



var _windup_timer = 0.0

func state_chase(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	# движение на игрока
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	
	update_move_animation()

	if dist <= attack_range:
		_windup_timer = windup_time
		print("ожидание - ", windup_time)
		print("вошел в состояние attack_windup")
		state = State.ATTACK_WINDUP
		

var flag_last_direction = 0
func update_move_animation():
	flag_last_direction = 1
	# Горизонтальное движение - анимация "вид сбоку"
	animBossSprite.play("бег_с_боку")
	# Разворот спрайта в направлении движения
	if abs(velocity.x) > 5: # задаем типо чувствительность, то есть будет менять направление при изменении хотя бы 5 пикселей
		if sign(animBossSprite.scale.x) != sign(velocity.x):
			animBossSprite.scale.x *= -1



func state_attack_windup(delta):
	#print(_windup_timer)
	velocity = Vector2.ZERO
	update_idle_animation()

	_windup_timer -= delta
	if _windup_timer <= 0:
		#state = State.ATTACK
		enter_attack()


func enter_attack():
	print("вошел в состояние attack")
	state = State.ATTACK
	_attack_timer = attack_duration
	_attack_finished = false

	velocity = Vector2.ZERO
	#face_player()
	animBossSprite.play("атака")
	
	var player = get_tree().get_first_node_in_group("игрок")
	# Этот вызов возвращает первый узел, который состоит в группе "игрок" и проверяет пересекается ли он с хитбоксом
	await get_tree().create_timer(0.5).timeout
	var dorobotka = 0 # вместо таймера наносить урон на конкретный кадр
	if not _damage_applied and $"ОбластьАтаки".overlaps_body(player): 
		player.take_damage(attack_damage)
		_damage_applied = true


var _attack_finished = false
var attack_duration = 0.75 # длительность атаки
var dorobotka = 0 # изменить выше на длительность анимации
var _attack_timer = 0.0

var _damage_applied = false
func state_attack(delta):
	velocity = Vector2.ZERO
	
	#var player = get_tree().get_first_node_in_group("игрок")
	#if not player:
		#return
	#var dir_x = player.global_position.x - global_position.x
	#if dir_x != 0:
		#animBossSprite.scale.x = sign(dir_x)
	
	_attack_timer -= delta
	
	if _attack_timer <= 0:
		_attack_finished = true
	
	if _attack_finished:
		_attack_finished = false
		_damage_applied = false
		_recover_timer = recover_time
		#state = State.RECOVER
		print("вошел в состояние reposition")
		state = State.REPOSITION


var _recover_timer = 0.0

func state_recover(delta):
	velocity = Vector2.ZERO
	update_idle_animation()
	_recover_timer -= delta
	if _recover_timer > 0:
		return # если время ожидания не кончилось, ничего не делаем

	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist < attack_range:
		print("вошел в состояние attack_windup")
		state = State.ATTACK_WINDUP
	else:
		print("вошел в состояние chase")
		state = State.CHASE


func state_reposition(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return
		
	update_stuck_check(delta)
	update_move_animation()

	#var dir = (global_position - player.global_position).normalized()
	var dir = get_spiral_escape_direction(player.global_position)
	velocity = dir * reposition_speed

	var dist = global_position.distance_to(player.global_position)
	if dist >= optimal_range:
		print("вошел в состояние recover")
		state = State.RECOVER # отбегает и ждет немного перед следующей атакой
	
	# если застряли
	if _stuck_timer >= stuck_time:
		if dist <= block_enter_distance:
			enter_block()
		else:
			state = State.RECOVER


func get_spiral_escape_direction(player_pos: Vector2) -> Vector2:
	var from_player = (global_position - player_pos).normalized()
	var tangent = Vector2(-from_player.y, from_player.x)
	return (from_player * 0.6 + tangent * 0.4).normalized()
	# Коэффициенты 0.7 / 0.3 можешь крутить:
	# больше tangent → сильнее кружит
	# больше from_player → быстрее уходит


func update_stuck_check(delta):
	if global_position.distance_to(_last_position) < stuck_distance_threshold:
		_stuck_timer += delta
	else:
		_stuck_timer = 0.0
	_last_position = global_position


func enter_block():
	state = State.BLOCK
	velocity = Vector2.ZERO
	animBossSprite.play("блок")


func state_block(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	velocity = Vector2.ZERO
	
	var dir_x = player.global_position.x - global_position.x
	if dir_x != 0:
		animBossSprite.scale.x = sign(dir_x)

	if dist >= block_exit_distance:
		state = State.RECOVER


func die():
	state = State.DEAD
	animBossSprite.play("смерть")
	await get_tree().create_timer(3.5).timeout # ждем конца анимации (2.5) и еще чуть чуть
	queue_free()
	
