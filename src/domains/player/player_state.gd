extends RefCounted


var location: Vector2 = Vector2.ZERO

var time: Dictionary = {
	"day": 1,
	"hour": 8,
	"minute": 0
}


static func from_dictionary(data: Dictionary):
	var state = new()

	var location_data: Dictionary = data.get(
		"location",
		{}
	)

	state.location = Vector2(
		float(location_data.get("x", 0.0)),
		float(location_data.get("y", 0.0))
	)

	var time_data: Dictionary = data.get(
		"time",
		{}
	)

	state.time = {
		"day": int(time_data.get("day", 1)),
		"hour": int(time_data.get("hour", 8)),
		"minute": int(time_data.get("minute", 0))
	}

	return state


func to_dictionary() -> Dictionary:
	return {
		"location": {
			"x": location.x,
			"y": location.y
		},
		"time": time.duplicate(true)
	}


func set_location(new_location: Vector2) -> void:
	location = new_location


func get_location() -> Vector2:
	return location


func set_time(new_time: Dictionary) -> void:
	time = {
		"day": int(new_time.get("day", 1)),
		"hour": int(new_time.get("hour", 8)),
		"minute": int(new_time.get("minute", 0))
	}


func get_time() -> Dictionary:
	return time.duplicate(true)