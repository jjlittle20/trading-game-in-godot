extends Node2D

const POI_MARKER_SCENE := preload("res://src/presentation/world_map/poi_marker/poi_marker.tscn")

const PLAYER_SCENE := preload("res://src/presentation/player/player.tscn")


func _ready() -> void:
	_spawn_poi_markers()
	spawn_player_on_world_map()


func _draw() -> void:
	_draw_world_map_roads()


func _spawn_poi_markers() -> void:
	var pois: Array[Dictionary] = Game.world.get_all_pois()

	for poi in pois:
		var poi_id: String = str(poi.get("id", ""))

		if poi_id.is_empty():
			push_error("Cannot spawn a POI marker without an id")
			continue

		var coords: Dictionary = poi.get("coords", { })

		if coords.is_empty():
			push_error("POI '%s' does not contain coordinates" % poi_id)
			continue

		var marker = POI_MARKER_SCENE.instantiate()

		marker.poiID = poi_id
		marker.position = Vector2(float(coords.get("x", 0.0)), float(coords.get("y", 0.0)))

		marker.enterPOI.connect(_on_area_2d_enter_poi)

		add_child(marker)


func _draw_world_map_roads() -> void:
	var pois: Array[Dictionary] = Game.world.get_all_pois()

	for poi in pois:
		var road_connections: Array[Dictionary] = Game.world.get_poi_road_connections(
			poi.get("id", "")
		)

		for road in road_connections:
			print("Drawing road from %s to %s" % [poi.get("id", ""), road.get("target_poi_id", "")])
			var end_poi_id: String = road.get("target_poi_id", "")
			var end_poi: Dictionary = Game.world.get_poi(end_poi_id)

			if end_poi.is_empty():
				continue
			if not Game.world.is_poi_discovered(end_poi_id):
				continue

			var start_coords: Dictionary = poi.get("coords", { })
			var end_coords: Dictionary = end_poi.get("coords", { })

			if start_coords.is_empty() or end_coords.is_empty():
				push_error("Road does not contain valid start and end coordinates")
				continue

			var start_point: Vector2 = Vector2(
				float(start_coords.get("x", 0.0)),
				float(start_coords.get("y", 0.0)),
			)
			var end_point: Vector2 = Vector2(
				float(end_coords.get("x", 0.0)),
				float(end_coords.get("y", 0.0)),
			)

			draw_line(start_point, end_point, Color.WHITE, 2.0)


func _on_area_2d_enter_poi(poi_id: String) -> void:
	if not Game.world.has_poi(poi_id):
		push_error("Unknown POI: %s" % poi_id)
		return

	var scene_path: String = (Game.world.get_poi_scene_path(poi_id))

	if scene_path.is_empty():
		push_error("POI '%s' has no scene path" % poi_id)
		return

	var location_saved: bool = Game.player.set_location(Game.world.get_poi_position(poi_id))

	if not location_saved:
		push_error("Could not save location before entering %s" % poi_id)
		return

	var time_saved: bool = Game.clock.save()

	if not time_saved:
		push_error("Could not save time before entering %s" % poi_id)
		return

	var entered: bool = Game.world.enter_poi(poi_id)

	if not entered:
		return

	load_poi(scene_path)


func load_poi(file_path: String) -> void:
	Game.scenes.load_scene(file_path)


func spawn_player_on_world_map() -> void:
	var player_node = PLAYER_SCENE.instantiate()

	player_node.global_position = (Game.player.get_location())

	add_child(player_node)
