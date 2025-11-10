extends CharacterBody2D

@onready var health_bar = $HealthBar
@onready var sprite = $Sprite2D  # если он есть

@export var health := 3  # можно задавать в редакторе
@export var max_health := 3
@export var move_speed := 50.0


@export_group("Enemy Damage")
@export var contact_damage := 1  # Урон от прикосновения
@export var attack_damage := 2   # Урон от будущих атак

# Сигнал для урона вместо жесткой привязки
signal took_damage(position, amount, is_crit)

func _ready():
	if health > max_health:
		max_health = health
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Подключаем сигнал к менеджеру	
	took_damage.connect(DamageNumbersManager.show_damage)


func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

func take_damage(amount := 1, is_crit = false):
	health -= amount
	health_bar.value = health  # обновляем полоску
	
	took_damage.emit(calculate_damage_position(), amount, is_crit)
	
	print("Осталось HP: ", health)
	if health <= 0:
		die()

func calculate_damage_position() -> Vector2:
	# Надежное вычисление позиции
	if sprite:
		# половина размера спрайта и на 20 повыше
		return global_position - Vector2(sprite.texture.get_width() * sprite.scale.x * 0.5, 
		sprite.texture.get_height() * sprite.scale.y * 0.5 + 20) 
	else:
		return global_position - Vector2(0, 50)  # fallback

func die():
	queue_free()


# Враг наносит урон игроку
func deal_contact_damage():
	return contact_damage
