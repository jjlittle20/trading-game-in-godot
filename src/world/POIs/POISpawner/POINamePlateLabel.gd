extends Label

func _ready() -> void:
	self.text = PoiManager.getPOIName("home_town")
