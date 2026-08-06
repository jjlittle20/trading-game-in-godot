extends RefCounted

const DefinitionRegistry = preload("res://src/core/data/definition_registry.gd")

var _registry = DefinitionRegistry.new()


func load_from_file(path: String) -> bool:
	var loaded_data = JsonFileService.read_json(path)

	if loaded_data == null:
		push_error("PoiRepository could not load: %s" % path)
		return false

	_registry.clear()

	if loaded_data is Array:
		return _load_from_array(loaded_data, path)

	if loaded_data is Dictionary:
		return _load_from_dictionary(loaded_data, path)

	push_error("POI file root must be an Array or Dictionary: %s" % path)

	return false


func get_poi(poi_id: String) -> Dictionary:
	return _registry.get_definition(poi_id)


func has_poi(poi_id: String) -> bool:
	return _registry.has_definition(poi_id)


func get_all_pois() -> Array[Dictionary]:
	return _registry.get_all()


func get_poi_ids() -> Array[String]:
	return _registry.get_ids()


func get_poi_count() -> int:
	return _registry.size()


func _load_from_array(poi_list: Array, source_path: String) -> bool:
	var loaded_successfully := _registry.register_many(poi_list, source_path)

	if loaded_successfully:
		print("Loaded %d POIs from %s" % [_registry.size(), source_path])

	return loaded_successfully


func _load_from_dictionary(poi_data: Dictionary, source_path: String) -> bool:
	# Supports a wrapper structure such as:
	# {
	#     "pois": [...]
	# }
	if poi_data.has("pois"):
		var wrapped_pois = poi_data["pois"]

		if not wrapped_pois is Array:
			push_error("'pois' must contain an Array in %s" % source_path)
			return false

		return _load_from_array(wrapped_pois, source_path)

	# Supports the existing keyed format:
	# {
	#     "home_town": {
	#         "name": "Home Town"
	#     }
	# }
	var definitions: Array = []

	for poi_id in poi_data.keys():
		var raw_definition = poi_data[poi_id]

		if not raw_definition is Dictionary:
			push_error("POI '%s' must be a Dictionary" % str(poi_id))
			continue

		var definition: Dictionary = raw_definition.duplicate(true)

		# Preserve an existing id, otherwise use the dictionary key.
		if not definition.has("id"):
			definition["id"] = str(poi_id)

		definitions.append(definition)

	return _load_from_array(definitions, source_path)
