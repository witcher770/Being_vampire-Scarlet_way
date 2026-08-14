extends Enemy

@onready var anim_slime = $AnimatedSprite2D

func _ready():
	# дробная часть усиления будет отбрасываться
	health = 5 * GameState.enemy_power
	contact_damage = contact_damage * GameState.enemy_power
	super._ready()




func _process_combat(delta):

	anim_slime.play("бег_слищь_скелет")

	move_towards_player()
