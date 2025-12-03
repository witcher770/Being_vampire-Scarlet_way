extends "res://сцены/враги/враг.gd"

enum State {
	IDLE, # ожидание, пока игрок не войдёт в радиус агро
	CHASE, # преследование игрока
	ATTACK_WINDUP, # подготовка к атаке (телеграф - визульный сигнал)
	ATTACK, # удар
	RECOVER, # короткая «перезарядка» после удара
	REPOSITION # перемещение для удержания оптимальной дистанции (отступление)
}

var state : State = State.IDLE

@export var aggro_range = 300.0 # дистанция на которой босс тебя замечает
@export var attack_range = 25.0 # дистанция на которой босс атакует
@export var windup_time = 0.4 # время на подготовку атаки. типо чтобы игрок успел увернуться
@export var recover_time = 3 # как часто атакует в секундах
@export var reposition_speed = 180.0 # скорость отступления
@export var optimal_range = 200.0 # дистанция переключения с отступления на нападение

func _ready():
	move_speed = 140.0
	super._ready() # вызываем родительский ready


func _process_ai(delta):
	match state:
		State.IDLE:
			print("вошел в состояние idle")
			state_idle(delta)

		State.CHASE:
			print("вошел в состояние chase")
			state_chase(delta)
			

		State.ATTACK_WINDUP:
			print("вошел в состояние attack_windup")
			state_attack_windup(delta)

		State.ATTACK:
			print("вошел в состояние attack")
			state_attack(delta)

		State.RECOVER:
			print("вошел в состояние recover")
			state_recover(delta)

		State.REPOSITION:
			print("вошел в состояние reposition")
			state_reposition(delta)
			
	#print("вошел в состояние - ")
	move_and_slide()


func state_idle(delta): # работает
	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return

	if global_position.distance_to(player.global_position) <= aggro_range:
		state = State.CHASE


var _windup_timer = 0.0

func state_chase(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	# движение на игрока
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed

	if dist <= attack_range:
		_windup_timer = windup_time
		print("ожидание - ", windup_time)
		state = State.ATTACK_WINDUP
		


func state_attack_windup(delta):
	print(_windup_timer)
	velocity = Vector2.ZERO

	_windup_timer -= delta
	if _windup_timer <= 0:
		state = State.ATTACK


var _attack_finished = false
var attack_duration = 0.6 # длительность атаки
var _attack_timer = 0.0


func state_attack(delta):
	velocity = Vector2.ZERO
	if _attack_timer <= 0:
		_attack_timer = attack_duration
	
	# Этот вызов возвращает первый узел, который состоит в группе "игрок" и проверяет пересекается ли он с хитбоксом
	if $"ОбластьАтаки".overlaps_body(get_tree().get_first_node_in_group("игрок")): 
		get_tree().get_first_node_in_group("игрок").take_damage(attack_damage)
		_attack_finished = true
	
	_attack_timer -= delta
	
	if _attack_timer <= 0:
		_attack_finished = true
	
	if _attack_finished:
		_attack_finished = false
		_recover_timer = recover_time
		#state = State.RECOVER
		state = State.REPOSITION


var _recover_timer = 0.0

func state_recover(delta):
	velocity = Vector2.ZERO
	_recover_timer -= delta
	if _recover_timer > 0:
		return # если время ожидания не кончилось, ничего не делаем

	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist < attack_range:
		state = State.ATTACK_WINDUP
	else:
		state = State.CHASE


func state_reposition(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if not player:
		return

	var dir = (global_position - player.global_position).normalized()
	velocity = dir * reposition_speed

	var dist = global_position.distance_to(player.global_position)
	if dist >= optimal_range:
		state = State.RECOVER # отбегает и ждет немного перед следующей атакой
