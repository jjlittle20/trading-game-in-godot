extends RefCounted

const DefinitionRegistry = preload("res://src/core/data/definition_registry.gd")

var _registry = DefinitionRegistry.new()


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


func update_poi(poi_id: String, poi: Dictionary) -> bool:
	if not _registry.has_definition(poi_id):
		push_error("Cannot update unknown POI: %s" % poi_id)
		return false

	return _registry.update_definition(poi_id, poi)


func _load_from_array(poi_list: Array, source_path: String) -> bool:
	var loaded_successfully := _registry.register_many(poi_list, source_path)

	if loaded_successfully:
		print("Loaded %d POIs from %s" % [_registry.size(), source_path])

	return loaded_successfully


func load_from_dictionary(poi_data: Dictionary, source_path: String) -> bool:
	var definitions: Array = []

	for poi_id in poi_data.keys():
		var raw_definition = poi_data[poi_id]

		if not raw_definition is Dictionary:
			push_error("POI '%s' must be a Dictionary" % str(poi_id))
			continue

		var definition: Dictionary = raw_definition.duplicate(true)

		if not definition.has("id"):
			definition["id"] = str(poi_id)

		definitions.append(definition)

	return _load_from_array(definitions, source_path)
