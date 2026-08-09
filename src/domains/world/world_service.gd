extends RefCounted

signal poi_entered(poi_id: String)
# signal poi_definitions_loaded(poi_count: int)
var _current_poi_id: String = ""

var _poi_repository = null

var _save_service = null


func _init(poi_repository, save_service) -> void:
	_poi_repository = poi_repository
	_save_service = save_service


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


func is_poi_discovered(poi_id: String) -> bool:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		return false

	return bool(poi.get("discovered", false))


func discover_poi(poi_id: String) -> void:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		push_error("Cannot discover unknown POI: %s" % poi_id)
		return

	if bool(poi.get("discovered", false)):
		return

	poi["discovered"] = true

	update_poi(poi_id, poi)


func get_poi_road_connections(poi_id: String) -> Array[Dictionary]:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		return []

	var raw_roads = poi.get("road_connections", [])

	if not raw_roads is Array:
		push_error("POI '%s' has invalid roads data" % poi_id)
		return []

	var roads: Array[Dictionary] = []

	for road in raw_roads:
		if road is Dictionary:
			roads.append(road)
		else:
			push_error("POI '%s' contains an invalid road connection" % poi_id)

	return roads


func poi_array_to_dictionary(pois: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = { }

	for poi: Dictionary in pois:
		var poi_id: String = poi.get("id", "")

		if poi_id.is_empty():
			push_error("POI is missing an id")
			continue

		result[poi_id] = poi

	return result


func update_poi(poi_id: String, poi: Dictionary) -> bool:
	if _poi_repository == null:
		push_error("WorldService has no PoiRepository")
		return false

	if not _poi_repository.update_poi(poi_id, poi):
		return false

	var pois: Dictionary = poi_array_to_dictionary(_poi_repository.get_all_pois())

	return save_poi(pois)


func save_poi(pois: Dictionary) -> bool:
	if _save_service == null:
		push_error("WorldService has no SaveService")
		return false

	if _poi_repository == null:
		push_error("WorldService has no POI repository")
		return false

	return _save_service.save_poi_data(pois)
