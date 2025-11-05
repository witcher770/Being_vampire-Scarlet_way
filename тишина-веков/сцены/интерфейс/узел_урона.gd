extends Label

func _ready() -> void:
	#print("Я появился в:", position, "  мой глобальный родитель:", get_parent().name)
	pass


func show_damage(amount, is_crit = false):
	text = "-" + str(amount)
	if is_crit:
		add_theme_color_override("font_color", Color.RED)
		scale = Vector2(1, 1) # задаем размер крита, сейчас по умолчанию масштаб 0.5
	#else:
		#add_theme_color_override("font_color", Color.WHITE)
		#scale = Vector2(1, 1)
	$AnimationPlayer.play("damage")
