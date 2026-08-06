extends Node


func get_poi(poi_id: String) -> Dictionary:
	if Game.world == null:
		push_error("Game.world is not initialised")
		return { }

	return Game.world.get_poi(poi_id)


func has_poi(poi_id: String) -> bool:
	if Game.world == null:
		return false

	return Game.world.has_poi(poi_id)


func get_all_pois() -> Array[Dictionary]:
	if Game.world == null:
		return []

	return Game.world.get_all_pois()


func get_poi_ids() -> Array[String]:
	if Game.world == null:
		return []

	return Game.world.get_poi_ids()


func get_poi_interactions(poi_id: String) -> Array:
	var poi: Dictionary = get_poi(poi_id)

	if poi.is_empty():
		return []

	var interactions = poi.get("interactions", [])

	if not interactions is Array:
		push_error("POI '%s' has invalid interactions data" % poi_id)
		return []

	return interactions.duplicate(true)

# Temporary compatibility with your existing camelCase calls.


func getPOI(poi_id: String) -> Dictionary:
	return get_poi(poi_id)


func getPOIInteractions(poi_id: String) -> Array:
	return get_poi_interactions(poi_id)
