class_name JsonFileService
extends RefCounted


static func read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("JSON file does not exist: %s" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error(
			"Could not open JSON file '%s'. Error code: %s"
			% [path, FileAccess.get_open_error()]
		)
		return null

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_error := json.parse(json_text)

	if parse_error != OK:
		push_error(
			"Invalid JSON in '%s' at line %d: %s"
			% [
				path,
				json.get_error_line(),
				json.get_error_message()
			]
		)
		return null

	return json.data


static func write_json(
	path: String,
	data: Variant,
	indent: String = "\t"
) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error(
			"Could not write JSON file '%s'. Error code: %s"
			% [path, FileAccess.get_open_error()]
		)
		return false

	file.store_string(JSON.stringify(data, indent))
	file.close()

	return true