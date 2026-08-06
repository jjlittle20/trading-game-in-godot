extends RefCounted

signal poi_entered(poi_id: String)
# signal poi_definitions_loaded(poi_count: int)
var _current_poi_id: String = ""

var _poi_repository = null


func _init(poi_repository) -> void:
	_poi_repository = poi_repository


func get_poi(poi_id: String) -> Dictionary:
	if _poi_repository == null:
		push_error("WorldService has no PoiRepository")
		return { }

	return _poi_repository.get_poi(poi_id)


func has_poi(poi_id: String) -> bool:
	if _poi_repository == null:
		return false

	return _poi_repository.has_poi(poi_id)


func get_all_pois() -> Array[Dictionary]:
	if _poi_repository == null:
		return []

	return _poi_repository.get_all_pois()


func get_poi_name(poi_id: String) -> String:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		return ""

	return str(poi.get("name", ""))


func get_poi_ids() -> Array[String]:
	if _poi_repository == null:
		return []

	return _poi_repository.get_poi_ids()


func get_poi_count() -> int:
	if _poi_repository == null:
		return 0

	return _poi_repository.get_poi_count()


func enter_poi(poi_id: String) -> bool:
	if not has_poi(poi_id):
		push_error("Cannot enter unknown POI: %s" % poi_id)
		return false

	_current_poi_id = poi_id
	poi_entered.emit(poi_id)

	return true


func get_current_poi_id() -> String:
	return _current_poi_id


func get_current_poi() -> Dictionary:
	if _current_poi_id.is_empty():
		push_warning("No current POI has been selected")
		return { }

	return get_poi(_current_poi_id)


func leave_current_poi() -> void:
	_current_poi_id = ""


func get_poi_position(poi_id: String) -> Vector2:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		return Vector2.ZERO

	var coords: Dictionary = poi.get("coords", { })

	return Vector2(float(coords.get("x", 0.0)), float(coords.get("y", 0.0)))


func get_poi_scene_path(poi_id: String) -> String:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		return ""

	return str(poi.get("filePath", ""))


func get_poi_interactions(poi_id: String) -> Array:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		return []

	var interactions = poi.get("interactions", [])

	if not interactions is Array:
		push_error("POI '%s' has invalid interactions data" % poi_id)
		return []

	return interactions.duplicate(true)
