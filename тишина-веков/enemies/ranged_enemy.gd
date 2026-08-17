extends Enemy

@export var preferred_distance := 180.0
@export var attack_cooldown := 2.0
@export var windup_time := 0.35
@export var recovery_time := 0.4
@export var projectile_scene: PackedScene
@export var projectile_speed := 220.0

var attack_timer := 0.0

func _ready():
	max_health = 6
	move_speed = 45
	attack_damage = 3
	aggro_range = 200.0
	lose_aggro_range = 250.0
	super._ready()


func _process_combat(delta):
	if not can_attack():
		return
	
	attack_timer -= delta
	var distance = global_position.distance_to(player.global_position)
	
	if distance < 100:
		move_away_from_player()
	elif distance > preferred_distance:
		move_towards_player()
	else:
		stop_moving()
		if attack_timer <= 0:
			attack_timer = attack_cooldown
			start_attack(windup_time, recovery_time)


func _on_attack_execute() -> void:
	if not projectile_scene:
		push_warning("Archer: не назначен projectile_scene")
		return

	var projectile = projectile_scene.instantiate()
	projectile.direction = global_position.direction_to(player.global_position)
	projectile.speed = projectile_speed
	projectile.damage = attack_damage

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + projectile.direction * 20.0
