extends RefCounted

const SHOP_LEVEL_ORDER: Array[String] = ["BASIC", "ADVANCED", "ELITE"]

var _shop_repository = null
var _item_service = null


func _init(shop_repository, item_service) -> void:
	_shop_repository = shop_repository
	_item_service = item_service


func has_shop(shop_id: String) -> bool:
	if _shop_repository == null:
		return false

	return _shop_repository.has_shop(shop_id)


func get_shop(shop_id: String) -> Dictionary:
	if _shop_repository == null:
		push_error("ShopService has no ShopRepository")
		return { }

	return _shop_repository.get_shop(shop_id)


func get_shop_ids() -> Array[String]:
	if _shop_repository == null:
		return []

	return _shop_repository.get_shop_ids()


func get_shop_count() -> int:
	if _shop_repository == null:
		return 0

	return _shop_repository.get_shop_count()


func get_stock_ids(
	shop_id: String,
	level: String,
	include_lower_levels: bool = true,
) -> Array[String]:
	if not has_shop(shop_id):
		push_error("Unknown shop: %s" % shop_id)
		return []

	var normalised_level: String = level.to_upper()
	var requested_level_index: int = (SHOP_LEVEL_ORDER.find(normalised_level))

	if requested_level_index == -1:
		push_error("Unknown shop level: %s" % level)
		return []

	var stock_ids: Array[String] = []

	if include_lower_levels:
		for level_index in range(requested_level_index + 1):
			var stock_level: String = (SHOP_LEVEL_ORDER[level_index])

			_append_unique_stock(
				stock_ids,
				_shop_repository.get_stock_for_level(shop_id, stock_level),
			)
	else:
		_append_unique_stock(
			stock_ids,
			_shop_repository.get_stock_for_level(shop_id, normalised_level),
		)

	return stock_ids


func get_stock_items(
	shop_id: String,
	level: String,
	include_lower_levels: bool = true,
) -> Array[Dictionary]:
	var stock_ids: Array[String] = get_stock_ids(shop_id, level, include_lower_levels)

	var items: Array[Dictionary] = []

	for item_id in stock_ids:
		if not _item_service.has_item(item_id):
			push_error("Shop '%s' references unknown item '%s'" % [shop_id, item_id])
			continue

		items.append(_item_service.get_item(item_id))

	return items


func validate_shop_stock() -> bool:
	var is_valid: bool = true

	for shop_id in get_shop_ids():
		for level in SHOP_LEVEL_ORDER:
			var stock_ids: Array[String] = (_shop_repository.get_stock_for_level(shop_id, level))

			for item_id in stock_ids:
				if not _item_service.has_item(item_id):
					push_error(
						"Shop '%s' level '%s' references unknown item '%s'"
						% [shop_id, level, item_id]
					)

					is_valid = false

	return is_valid


func _append_unique_stock(target: Array[String], source: Array[String]) -> void:
	for item_id in source:
		if not target.has(item_id):
			target.append(item_id)
