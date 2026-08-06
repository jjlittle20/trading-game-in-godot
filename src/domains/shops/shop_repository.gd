extends RefCounted

const VALID_LEVELS: Array[String] = ["BASIC", "ADVANCED", "ELITE"]

var _shops: Dictionary = { }


func load_from_file(path: String) -> bool:
	var loaded_data = JsonFileService.read_json(path)

	if loaded_data == null:
		push_error("ShopRepository could not load: %s" % path)
		return false

	if not loaded_data is Dictionary:
		push_error("Shop file root must be a Dictionary: %s" % path)
		return false

	_shops.clear()

	var all_loaded: bool = true

	for shop_key in loaded_data.keys():
		var shop_id: String = str(shop_key).to_upper()
		var raw_shop = loaded_data[shop_key]

		if not raw_shop is Dictionary:
			push_error("Shop '%s' must be a Dictionary" % shop_id)

			all_loaded = false
			continue

		var shop_definition: Dictionary = { "id": shop_id, "levels": { } }

		for level in VALID_LEVELS:
			var stock = raw_shop.get(level, [])

			if not stock is Array:
				push_error("Shop '%s' level '%s' must contain an Array" % [shop_id, level])

				all_loaded = false
				stock = []

			shop_definition["levels"][level] = (stock.duplicate(true))

		_shops[shop_id] = shop_definition

	print("Loaded %d shops from %s" % [_shops.size(), path])

	return all_loaded


func has_shop(shop_id: String) -> bool:
	return _shops.has(shop_id.to_upper())


func get_shop(shop_id: String) -> Dictionary:
	var normalised_id: String = shop_id.to_upper()

	if not _shops.has(normalised_id):
		push_error("Unknown shop: %s" % shop_id)
		return { }

	return _shops[normalised_id].duplicate(true)


func get_shop_ids() -> Array[String]:
	var results: Array[String] = []

	for shop_id in _shops.keys():
		results.append(str(shop_id))

	return results


func get_shop_count() -> int:
	return _shops.size()


func get_stock_for_level(shop_id: String, level: String) -> Array[String]:
	var shop: Dictionary = get_shop(shop_id)

	if shop.is_empty():
		return []

	var normalised_level: String = level.to_upper()

	if not VALID_LEVELS.has(normalised_level):
		push_error("Unknown shop level: %s" % level)
		return []

	var levels: Dictionary = shop.get("levels", { })
	var raw_stock = levels.get(normalised_level, [])

	var results: Array[String] = []

	for item_id in raw_stock:
		results.append(str(item_id))

	return results
