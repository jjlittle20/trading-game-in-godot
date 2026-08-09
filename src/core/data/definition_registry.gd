extends RefCounted

var _definitions: Dictionary = { }


func register_definition(
	definition: Dictionary,
	source_name: String = "unknown",
	allow_override: bool = false,
) -> bool:
	var definition_id: String = str(definition.get("id", ""))

	if definition_id.is_empty():
		push_error("Definition from '%s' is missing an id" % source_name)
		return false

	if _definitions.has(definition_id) and not allow_override:
		push_error("Duplicate definition id '%s' from '%s'" % [definition_id, source_name])
		return false

	_definitions[definition_id] = definition.duplicate(true)
	return true


func register_many(
	definitions: Array,
	source_name: String = "unknown",
	allow_override: bool = false,
) -> bool:
	var all_registered := true

	for definition in definitions:
		if not definition is Dictionary:
			push_error("Invalid definition in '%s': expected Dictionary" % source_name)
			all_registered = false
			continue

		var registered := register_definition(definition, source_name, allow_override)

		if not registered:
			all_registered = false

	return all_registered


func has_definition(definition_id: String) -> bool:
	return _definitions.has(definition_id)


func get_definition(definition_id: String) -> Dictionary:
	if not _definitions.has(definition_id):
		push_error("Unknown definition id: %s" % definition_id)
		return { }

	return _definitions[definition_id].duplicate(true)


func get_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []

	for definition in _definitions.values():
		results.append(definition.duplicate(true))

	return results


func get_ids() -> Array[String]:
	var results: Array[String] = []

	for definition_id in _definitions.keys():
		results.append(str(definition_id))

	return results


func size() -> int:
	return _definitions.size()


func clear() -> void:
	_definitions.clear()


func update_definition(definition_id: String, definition: Dictionary) -> bool:
	if not _definitions.has(definition_id):
		push_error("Cannot update unknown definition: %s" % definition_id)
		return false

	var updated_definition := definition.duplicate(true)
	updated_definition["id"] = definition_id

	_definitions[definition_id] = updated_definition

	return true
