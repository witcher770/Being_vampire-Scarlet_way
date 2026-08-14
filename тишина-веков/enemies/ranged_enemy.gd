extends Enemy

@export var preferred_distance := 180.0
@export var attack_cooldown := 2.0

var attack_timer := 0.0


func _ready():
	
	max_health = 6
	move_speed = 35
	attack_damage = 3
	
	super._ready()


func _process_combat(delta):
	
	attack_timer -= delta
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance < 100:
		move_away_from_player()
	
	elif distance > preferred_distance:
		move_towards_player()
	
	else:
		stop_moving()
		
		if attack_timer <= 0:
			shoot()


func move_away_from_player():
	var direction = player.global_position.direction_to(global_position)
	
	velocity = -1 * direction * move_speed 
	move_and_slide()


func shoot():
	attack_timer = attack_cooldown
	
	var dorabotka = 0 
	# сделать полноценную атаку animation - windup - hitbox - damage - recovery
	print("Стреляем!")
