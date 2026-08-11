@tool
extends EditorScript


func _run() -> void:
	print("")
	print("========================================")
	print("       GODOT DUPLICATE UID FIXER")
	print("========================================")
	print("")

	var uid_to_paths: Dictionary = {}

	# 1. Собираем все UID
	_scan_directory("res://", uid_to_paths)

	var duplicate_groups := 0
	var fixed_files := 0

	# 2. Ищем дубликаты
	for uid in uid_to_paths:
		var paths: Array = uid_to_paths[uid]

		if paths.size() <= 1:
			continue

		duplicate_groups += 1

		print("")
		print("DUPLICATE UID:")
		print("  ", uid)

		# Первый файл оставляем как есть.
		var original_path: String = paths[0]

		print("  KEEP:")
		print("    ", original_path)

		# Остальным генерируем новые UID.
		for i in range(1, paths.size()):
			var duplicate_path: String = paths[i]

			print("")
			print("  FIX:")
			print("    ", duplicate_path)

			var new_uid := ResourceUID.create_id()
			var new_uid_text := ResourceUID.id_to_text(new_uid)

			if _replace_scene_uid(duplicate_path, new_uid_text):
				print("    OLD: ", uid)
				print("    NEW: ", new_uid_text)

				fixed_files += 1
			else:
				print("    ERROR: failed to modify file!")

	print("")
	print("========================================")
	print("RESULT")
	print("========================================")
	print("Duplicate UID groups: ", duplicate_groups)
	print("Files fixed:          ", fixed_files)
	print("========================================")
	print("")

	if fixed_files > 0:
		print("UID repair completed.")
		print("")
		print("IMPORTANT:")
		print("Do not run the game yet.")
		print("First restart/check the project and rescan UIDs.")
	else:
		print("No duplicate UIDs found.")
		print("")


func _scan_directory(path: String, uid_to_paths: Dictionary) -> void:
	var dir := DirAccess.open(path)

	if dir == null:
		push_error("Cannot open directory: " + path)
		return

	dir.list_dir_begin()

	while true:
		var file_name := dir.get_next()

		if file_name == "":
			break

		if file_name == "." or file_name == "..":
			continue

		var full_path := path.path_join(file_name)

		if dir.current_is_dir():
			_scan_directory(full_path, uid_to_paths)
			continue

		if not file_name.ends_with(".tscn"):
			continue

		_read_scene_uid(full_path, uid_to_paths)

	dir.list_dir_end()


func _read_scene_uid(path: String, uid_to_paths: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Cannot read: " + path)
		return

	var text := file.get_as_text()
	file.close()

	var regex := RegEx.new()

	regex.compile(
		"\\[gd_scene[^\\]]*uid=\"([^\"]*)\"[^\\]]*\\]"
	)

	var match := regex.search(text)

	if match == null:
		print("WARNING: No UID found:")
		print("  ", path)
		return

	var uid_text: String = match.get_string(1)

	if uid_text.is_empty():
		print("WARNING: Empty UID:")
		print("  ", path)
		return

	if not uid_to_paths.has(uid_text):
		uid_to_paths[uid_text] = []

	uid_to_paths[uid_text].append(path)


func _replace_scene_uid(path: String, new_uid: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Cannot open for reading: " + path)
		return false

	var text := file.get_as_text()
	file.close()

	var regex := RegEx.new()

	regex.compile(
		"(\\[gd_scene[^\\]]*uid=\")([^\"]*)(\"[^\\]]*\\])"
	)

	var match := regex.search(text)

	if match == null:
		push_error("Could not find UID in: " + path)
		return false

	var replacement := (
		match.get_string(1)
		+ new_uid
		+ match.get_string(3)
	)

	text = (
		text.substr(0, match.get_start())
		+ replacement
		+ text.substr(match.get_end())
	)

	var output := FileAccess.open(path, FileAccess.WRITE)

	if output == null:
		push_error("Cannot open for writing: " + path)
		return false

	output.store_string(text)
	output.close()

	return true
