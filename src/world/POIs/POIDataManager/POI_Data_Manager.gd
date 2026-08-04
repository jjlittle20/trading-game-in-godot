extends Node

var POIDATAFILEPATH: String = "res://content/base/world/pois.json"
var POIData = JSON.parse_string(FileAccess.get_file_as_string(POIDATAFILEPATH))


func getPOIName(poiID: String) -> String:
	return POIData[poiID].name


func getPOIInteractions(poiID: String):
	return POIData[poiID].interactions
