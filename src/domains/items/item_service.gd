extends RefCounted

var _item_repository = null


func _init(item_repository) -> void:
	_item_repository = item_repository


func get_item(item_id: String) -> Dictionary:
	if _item_repository == null:
		push_error("ItemService has no ItemRepository")
		return { }

	return _item_repository.get_item(item_id)


func has_item(item_id: String) -> bool:
	if _item_repository == null:
		return false

	return _item_repository.has_item(item_id)


func get_all_items() -> Array[Dictionary]:
	if _item_repository == null:
		return []

	return _item_repository.get_all_items()


func get_item_ids() -> Array[String]:
	if _item_repository == null:
		return []

	return _item_repository.get_item_ids()


func get_item_count() -> int:
	if _item_repository == null:
		return 0

	return _item_repository.get_item_count()


func get_item_name(item_id: String) -> String:
	var item: Dictionary = get_item(item_id)

	if item.is_empty():
		return item_id

	return str(item.get("name", item_id))


func get_base_price(item_id: String) -> float:
	var item: Dictionary = get_item(item_id)

	if item.is_empty():
		return 0.0

	if item.has("base_price"):
		return float(item.get("base_price", 0.0))

	if item.has("basePrice"):
		return float(item.get("basePrice", 0.0))

	if item.has("cost"):
		return float(item.get("cost", 0.0))

	if item.has("price"):
		return float(item.get("price", 0.0))

	return 0.0


func get_categories() -> Array[String]:
	if _item_repository == null:
		return []

	return _item_repository.get_categories()


func get_items_by_category(category: String) -> Array[Dictionary]:
	if _item_repository == null:
		return []

	return _item_repository.get_items_by_category(category)


func get_item_category(item_id: String) -> String:
	var item: Dictionary = get_item(item_id)

	if item.is_empty():
		return ""

	return str(item.get("category", ""))
