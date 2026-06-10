extends Node

var _locations:Dictionary={}

func _ready()->void:
	_load_all_locations("res://resources/location")
	
	
func get_location(location_id:String)->Vector2i:
	if _locations.has(location_id):
		var loc=_locations.get(location_id)
		return loc.get_entry_position()
	else:
		return Vector2i.ZERO

func get_location_in_world(world_id:String,location_id:String) -> Vector2i:
	if _locations.has(location_id):
		var loc:LocationData=_locations.get(location_id)
		if loc.world_scene==world_id:
			return loc.get_entry_position()
		else:
			return Vector2i.ZERO
	else:
		return Vector2i.ZERO


func _load_all_locations(folder_path: String) -> void:
	var files = ResourceLoader.list_directory(folder_path)
	for file_name in files:
		if file_name.ends_with(".tres"):
			var res:LocationData = ResourceLoader.load(folder_path + "/"+ file_name)
			if res is LocationData and res.id != "":
				_locations[res.get_id()] = res
				
	print("LOADED ALL LOCATION")
