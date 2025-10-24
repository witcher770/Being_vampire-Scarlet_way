extends CharacterBody2D

# скрипт передвижения
@export var speed := 100.0  # можно менять из редактора
var facing_direction := Vector2.RIGHT  # по умолчанию вправо (направление области атаки)
@onready var animPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D


func _ready():
	randomize()
	$"область атаки".monitoring = false  # отключаем зону атаки сразу
	$"область атаки".body_entered.connect(_on_attack_hit)


func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	
	#if input_vector != Vector2.ZERO:
		#facing_direction = input_vector
		#animPlayer.play("бег_перед")
		#$"область атаки".position = facing_direction * 30  # смещаем вперёд (подбери значение по спрайту)


	if input_vector != Vector2.ZERO:
		facing_direction = input_vector
		
		# Простое определение по осям
		if input_vector.x != 0:
			# Горизонтальное движение
			animPlayer.play("бег_с_боку")
			if sign(sprite.scale.x) != sign(input_vector.x):
				sprite.scale.x *= -1

		elif input_vector.y > 0:
			# Движение вниз
			animPlayer.play("бег_перед")
		elif input_vector.y < 0:
			# Движение вверх
			animPlayer.play("бег_спина")
		
		$"область атаки".position = facing_direction * 30  # смещаем вперёд (подбери значение по спрайту)
	
	else:
		animPlayer.play('покой')

	velocity = input_vector * speed
	move_and_slide()

# скрипт атаки
@onready var attack_area = $"область атаки"

func _input(event):
	if Input.is_action_just_pressed("атака"):
		attack_area.monitoring = true
		await get_tree().create_timer(0.1).timeout
		attack_area.monitoring = false


# при попадании в атаку (не системная функция)
func _on_attack_hit(body): # body передается из сигнала по умолчанию(то что попало в область)
	if body.is_in_group("враги"):
		var damage = randi_range(1, 3)  # например, от 1 до 3 урона
		var is_crit = damage == 3
		print("число урона: ", damage," значение крита: ", is_crit)
		body.take_damage(damage, is_crit)
