extends RefCounted

const DefinitionRegistry = preload("res://src/core/data/definition_registry.gd")

var _registry = DefinitionRegistry.new()

var _items_by_category: Dictionary = { }


func load_from_file(path: String) -> bool:
	var loaded_data = JsonFileService.read_json(path)

	if loaded_data == null:
		push_error("ItemRepository could not load: %s" % path)
		return false

	_registry.clear()
	_items_by_category.clear()

	if loaded_data is Array:
		return _load_from_array(loaded_data, path, "ITEMS")

	if loaded_data is Dictionary:
		return _load_category_dictionary(loaded_data, path)

	push_error("Item file root must be an Array or Dictionary: %s" % path)

	return false


func get_item(item_id: String) -> Dictionary:
	return _registry.get_definition(item_id)


func has_item(item_id: String) -> bool:
	return _registry.has_definition(item_id)


func get_all_items() -> Array[Dictionary]:
	return _registry.get_all()


func get_item_ids() -> Array[String]:
	return _registry.get_ids()


func get_item_count() -> int:
	return _registry.size()


func get_categories() -> Array[String]:
	var categories: Array[String] = []

	for category in _items_by_category.keys():
		categories.append(str(category))

	return categories


func get_items_by_category(category: String) -> Array[Dictionary]:
	var normalised_category: String = category.to_upper()

	if not _items_by_category.has(normalised_category):
		return []

	var results: Array[Dictionary] = []

	for item_id in _items_by_category[normalised_category]:
		results.append(_registry.get_definition(str(item_id)))

	return results


func _load_category_dictionary(item_data: Dictionary, source_path: String) -> bool:
	var all_loaded: bool = true

	for category_key in item_data.keys():
		var category: String = str(category_key).to_upper()
		var category_items = item_data[category_key]

		if not category_items is Array:
			push_error("Item category '%s' must contain an Array in %s" % [category, source_path])

			all_loaded = false
			continue

		var category_loaded: bool = _load_from_array(category_items, source_path, category)

		if not category_loaded:
			all_loaded = false

	print(
		"Loaded %d items across %d categories from %s"
		% [_registry.size(), _items_by_category.size(), source_path]
	)

	return all_loaded


func _load_from_array(item_list: Array, source_path: String, category: String) -> bool:
	var all_loaded: bool = true
	var normalised_category: String = category.to_upper()

	if not _items_by_category.has(normalised_category):
		_items_by_category[normalised_category] = []

	for raw_item in item_list:
		if not raw_item is Dictionary:
			push_error("Invalid item in category '%s': expected Dictionary" % normalised_category)

			all_loaded = false
			continue

		var definition: Dictionary = raw_item.duplicate(true)

		var item_id: String = str(definition.get("id", ""))

		if item_id.is_empty():
			push_error("Item in category '%s' is missing an id" % normalised_category)

			all_loaded = false
			continue

		definition["category"] = normalised_category

		var registered: bool = (_registry.register_definition(definition, source_path))

		if not registered:
			all_loaded = false
			continue

		_items_by_category[normalised_category].append(item_id)

	return all_loaded
