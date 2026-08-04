extends Node2D

var POIData = PoiManager.POIData


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for key in POIData:
		var child = preload("res://src/world/POIs/POISpawner/POIMarker.tscn").instantiate()
		child.poiID = POIData[key].id
		var x = POIData[key].coords.x
		var y = POIData[key].coords.y
		child.position = Vector2(x, y)
		child.enterPOI.connect(_on_area_2d_enter_poi)

		self.add_child(child)
	spawnPlayerOnWorldMap()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_enter_poi(poiID: String) -> void:
	var poi = POIData[poiID]
	Game.player.set_location(Vector2(poi.coords.x, poi.coords.y))
	Game.player.set_time(WorldClock.get_time_int())
	loadPOI(poi.filePath)


func loadPOI(filePath) -> void:
	SceneLoader.load_scene(filePath)


func spawnPlayerOnWorldMap() -> void:
	var playerNode = preload("res://src/player/Player.tscn").instantiate()
	playerNode.global_position = Game.player.get_location()

	self.add_child(playerNode)
