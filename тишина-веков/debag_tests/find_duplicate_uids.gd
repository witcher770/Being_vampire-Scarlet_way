@tool
extends EditorScript


func _run() -> void:
	var uid_to_paths: Dictionary = {}
	var empty_uids: Array[String] = []

	_scan_directory("res://", uid_to_paths)

	print("")
	print("========================================")
	print("       GODOT UID SCAN")
	print("========================================")
	print("")

	var duplicate_count := 0

	for uid in uid_to_paths:
		var paths: Array = uid_to_paths[uid]

		if paths.size() > 1:
			duplicate_count += 1

			print("DUPLICATE UID:")
			print("  ", uid)

			for path in paths:
				print("    -> ", path)

			print("")

	print("----------------------------------------")
	print("Duplicate UID groups: ", duplicate_count)
	print("----------------------------------------")
	print("")

	if empty_uids.size() > 0:
		print("FILES WITH EMPTY UID:")
		for path in empty_uids:
			print("  -> ", path)

		print("")
		print("----------------------------------------")
		print("Empty UID files: ", empty_uids.size())
	else:
		print("No empty UIDs found.")

	print("")
	print("========================================")


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

		_scan_scene(full_path, uid_to_paths)

	dir.list_dir_end()


func _scan_scene(path: String, uid_to_paths: Dictionary) -> void:
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
		print("NO UID:")
		print("  -> ", path)
		return

	var uid: String = match.get_string(1)

	if uid.is_empty():
		print("EMPTY UID:")
		print("  -> ", path)
		return

	if not uid_to_paths.has(uid):
		uid_to_paths[uid] = []

	uid_to_paths[uid].append(path)
