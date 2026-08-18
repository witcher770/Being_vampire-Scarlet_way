extends Enemy

@export var attack_range := 35.0
@export var attack_cooldown := 1.5
@export var windup_time := 0.4
@export var recovery_time := 0.5
@export var hitbox_active_time := 0.15

@onready var hitbox: Area2D = $AttackHitbox

var attack_timer := 0.0
var _damaged_this_swing: Array = []


func _ready():
	max_health = 25
	move_speed = 12
	contact_damage = 4
	attack_damage = 6
	aggro_range = 100.0
	lose_aggro_range = 150.0
	
	super._ready()
	
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _process_combat(delta):
	if not can_attack():
		return
	
	attack_timer -= delta
	var distance = global_position.distance_to(player.global_position)
	
	if distance > attack_range:
		move_towards_player()
	else:
		stop_moving()
		if attack_timer <= 0:
			attack_timer = attack_cooldown
			start_attack(windup_time, recovery_time)


func _on_attack_execute() -> void:
	_damaged_this_swing.clear()
	hitbox.monitoring = true
	
	await get_tree().create_timer(hitbox_active_time).timeout
	if is_instance_valid(hitbox):
		hitbox.monitoring = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == player and body not in _damaged_this_swing:
		_damaged_this_swing.append(body)
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)


func _on_attack_windup_start(windup_time: float) -> void:
	super._on_attack_windup_start(windup_time)
	_show_range_indicator(windup_time)


func _show_range_indicator(duration: float) -> void:
	var pale_circle = _make_circle_polygon(attack_range, Color(1.0, 0.5, 0.5, 0.25))
	pale_circle.z_index = -2
	add_child(pale_circle)

	var dark_circle = _make_circle_polygon(attack_range, Color(0.5, 0.0, 0.0, 0.6))
	dark_circle.scale = Vector2.ZERO
	dark_circle.z_index = -1  # рисуется поверх бледного, оба - под спрайтами
	add_child(dark_circle)

	var tween = create_tween()
	tween.tween_property(dark_circle, "scale", Vector2.ONE, duration)
	tween.tween_callback(func():
		pale_circle.queue_free()
		dark_circle.queue_free()
	)


func _make_circle_polygon(radius: float, color: Color) -> Polygon2D:
	var circle = Polygon2D.new()
	var points := PackedVector2Array()
	var segments := 32
	for i in range(segments):
		var angle = TAU * i / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	circle.polygon = points
	circle.color = color
	return circle
