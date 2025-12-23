extends "res://сцены/враги/враг.gd"
@onready var animSl3 = $AnimatedSprite2D

func _ready():
	# дробная часть усиления будет отбрасываться
	health = 5 * GameState.enemy_power
	contact_damage = contact_damage * GameState.enemy_power
	super._ready()

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if player:
		if global_position.distance_to(player.global_position) < 70 or is_agr:
			animSl3.play("бег_слищь_скелет")
			is_agr = true
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
			move_and_slide()
		if global_position.distance_to(player.global_position) > 150: is_agr = false
