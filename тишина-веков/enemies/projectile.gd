extends Area2D
class_name EnemyProjectile

@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var speed: float = 200.0
var damage: float = 1.0

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
