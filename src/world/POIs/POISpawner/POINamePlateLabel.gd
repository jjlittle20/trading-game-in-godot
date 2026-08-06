extends Label


func _ready() -> void:
	var poi_id = Game.world.get_current_poi_id()
	self.text = Game.world.get_poi_name(poi_id)
