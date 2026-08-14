extends Enemy

@export var attack_range := 35.0
@export var attack_cooldown := 1.5

var attack_timer := 0.0


func _ready():
	
	max_health = 25
	move_speed = 12
	contact_damage = 4
	
	super._ready()


func _process_combat(delta):
	
	attack_timer -= delta
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance > attack_range:
		move_towards_player()
	else:
		stop_moving()
	
		if attack_timer <= 0:
			attack()


func attack():
	
	attack_timer = attack_cooldown
	var dorabotka = 0 
	# сделать полноценную атаку animation - windup - hitbox - damage - recovery
	
	print("Танк атакует!")
