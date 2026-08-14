extends Enemy

func _ready():
	max_health = 2
	move_speed = 60
	contact_damage = 1
	aggro_range = 100
	lose_aggro_range = 180
	
	super._ready()


func _process_combat(delta):

	move_towards_player()
