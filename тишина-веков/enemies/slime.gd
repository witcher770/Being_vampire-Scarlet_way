extends Enemy

@onready var anim_slime = $AnimatedSprite2D


func _process_combat(delta):

	anim_slime.play("бег_слищь_скелет")

	move_towards_player()
