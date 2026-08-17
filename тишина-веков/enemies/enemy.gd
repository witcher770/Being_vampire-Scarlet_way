extends CharacterBody2D
class_name Enemy

@onready var health_bar = $HealthBar
@onready var sprite = $Sprite2D

# BASE STATS
# =========================
@export_category("Stats")
@export var max_health: float = 5.0
@export var move_speed: float = 25.0

@export_category("Damage")
@export var contact_damage: int = 2
@export var attack_damage: int = 2

# AI
# =========================
@export_category("AI")
@export var aggro_range: float = 70.0
@export var lose_aggro_range: float = 150.0

var health: float
var player: Node2D = null
var is_aggro: bool = false

# SIGNALS
# =========================
signal took_damage(position, amount, is_crit, is_player)


enum EnemyRole {
	CHASER,
	FAST,
	TANK,
	RANGED
}

@export_category("Type_enemy")
@export var role: EnemyRole = EnemyRole.CHASER
# хз надо ли и как использовать в дочерних классах

func _ready():
	add_to_group("enemy")
	
	# дробная часть усиления будет отбрасываться
	health = max_health * GameState.enemy_power
	@warning_ignore("narrowing_conversion")
	contact_damage *= GameState.enemy_power
	attack_damage *= GameState.enemy_power
	
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Подключаем сигнал к менеджеру
	took_damage.connect(DamageNumbersManager.show_damage)

	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if not player:
		return
	
	update_aggro()
	
	if is_aggro:
		_process_combat(delta)
	else:
		_process_idle(delta)


# AI
# =========================

func update_aggro():
	var distance = global_position.distance_to(player.global_position)
	
	if not is_aggro and distance <= aggro_range:
		is_aggro = true
	elif is_aggro and distance >= lose_aggro_range:
		is_aggro = false


@warning_ignore("unused_parameter")
func _process_combat(delta):
	# Переопределяется конкретным врагом
	pass


@warning_ignore("unused_parameter")
func _process_idle(delta):
	velocity = Vector2.ZERO
	move_and_slide()


# MOVEMENT
# =========================

func move_towards_player():
	var direction = global_position.direction_to(player.global_position)
	
	velocity = direction * move_speed
	move_and_slide()


func move_away_from_player():
	var direction = player.global_position.direction_to(global_position)
	velocity = direction * move_speed
	move_and_slide()


func stop_moving():
	velocity = Vector2.ZERO
	move_and_slide()


func take_damage(amount: int = 1, is_crit: bool = false):
	health -= amount
	health_bar.value = health  # обновляем полоску
	
	took_damage.emit(calculate_damage_position(), amount, is_crit)
	
	print("Осталось HP: ", health)
	if health <= 0:
		die()


func calculate_damage_position() -> Vector2:
	# Надежное вычисление позиции
	if sprite and sprite.texture:
		# половина размера спрайта и на 20 повыше
		#print("ширина спрайта - ", sprite.texture.get_width() / 8)
		#print("середина спрайта - ", sprite.texture.get_width() / 8 * sprite.scale.x * 0.5)
		# еще делим на 8 тк 8 кадров
		return global_position - Vector2(sprite.texture.get_width() / 8 * sprite.scale.x * 0.5, \
		sprite.texture.get_height() / 8 * sprite.scale.y * 0.5 + 20) 
	else:
		print("спрайт не найден")
		return global_position - Vector2(0, 50)  # fallback


# DEATH
# =========================

func die():
	GameState.enemy_died()
	queue_free()


# ATTACK
# =========================
# Враг наносит урон игроку
func deal_contact_damage():
	return contact_damage


enum AttackPhase { NONE, WINDUP, RECOVER }
var attack_phase: AttackPhase = AttackPhase.NONE


## Можно ли начать новую атаку прямо сейчас (враг не занят другой атакой).
func can_attack() -> bool:
	return attack_phase == AttackPhase.NONE


## Стандартная последовательность атаки: замах (враг стоит на месте) -> исполнение
## (наносится урон, обязательно переопределяется в наследнике через _on_attack_execute())
## -> откат (снова стоит на месте) -> снова свободен. [br]
## [param windup_time] - Длительность замаха в секундах. [br]
## [param recovery_time] - Длительность отката после атаки в секундах.
func start_attack(windup_time: float, recovery_time: float) -> void:
	if not can_attack():
		return
	
	attack_phase = AttackPhase.WINDUP
	stop_moving()
	_on_attack_windup_start()
	
	await get_tree().create_timer(windup_time).timeout
	if not is_instance_valid(self):
		return
	
	await _on_attack_execute()
	if not is_instance_valid(self):
		return
	
	attack_phase = AttackPhase.RECOVER
	_on_attack_recovery_start()
	
	await get_tree().create_timer(recovery_time).timeout
	if not is_instance_valid(self):
		return
	
	attack_phase = AttackPhase.NONE


## Момент фактического нанесения урона. Обязательно переопределяется в наследнике -
## именно тут спавнится хитбокс/снаряд.
func _on_attack_execute() -> void:
	push_warning("%s: _on_attack_execute() не переопределён" % name)


## Вызывается в момент начала замаха. Переопределяется по желанию (анимация подготовки, подсветка).
func _on_attack_windup_start() -> void:
	pass


## Вызывается в момент начала отката после атаки. Переопределяется по желанию.
func _on_attack_recovery_start() -> void:
	pass
