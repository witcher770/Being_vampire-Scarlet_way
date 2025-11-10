extends Label

const UI_LAYER = 10

func _ready():
	# Убедимся что нод удалится если анимация не сработала
	await get_tree().create_timer(2.0).timeout
	if is_inside_tree():
		queue_free()

func show_damage(amount, is_crit = false, is_player = false):
	z_index = UI_LAYER
	
	text = "-" + str(amount)
	
	if is_crit:
		add_theme_color_override("font_color", Color.RED)
		scale = Vector2(1.2, 1.2)
	else:
		add_theme_color_override("font_color", Color.WHITE)
		scale = Vector2(0.8, 0.8)
	
	if is_player:
		add_theme_color_override("font_color", Color.DARK_BLUE)
		scale = Vector2(1, 1)
	
	# Безопасное воспроизведение анимации
	var anim_player = $AnimationNumber
	if anim_player and anim_player.has_animation("damage"):

		# Подключаемся к сигналу ДО запуска анимации
		anim_player.animation_finished.connect(_on_animation_finished)

		anim_player.play("damage")
	else:
		# Fallback анимация кодом
		var tween = create_tween()
		tween.tween_property(self, "position:y", position.y - 50, 0.5)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)

func _on_animation_finished(anim_name):
	queue_free()
