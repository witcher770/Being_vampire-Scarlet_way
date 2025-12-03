extends "res://сцены/враги/враг.gd"

func _process_ai(delta):
	var player = get_tree().get_first_node_in_group("игрок")
	if player:
		if global_position.distance_to(player.global_position) < 50 or is_agr:
			is_agr = true
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
			move_and_slide()
		if global_position.distance_to(player.global_position) > 150: is_agr = false
