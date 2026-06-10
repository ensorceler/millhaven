extends Node

# Interior scene paths per building
# Add all your interior scenes here
const INTERIOR_SCENES: Dictionary = {
	"tavern":    "res://scenes/tavern.tscn",
	"windmill":  "res://scenes/windmill_interior.tscn",
	"workshop":  "res://scenes/workshop_interior.tscn",
	"town_hall": "res://scenes/town_hall_interior.tscn",
	"farmstead": "res://scenes/farmstead_interior.tscn",
}

const BUILDING_NAMES: Dictionary = {
	"tavern":    "The Tavern",
	"windmill":  "The Windmill",
	"workshop":  "Marcus's Workshop",
	"town_hall": "Town Hall",
	"farmstead": "Thomas's Farmstead",
}

var _cctv_panel: CCTVPanel = null

func _ready() -> void:
	print("[CCTVManager] Ready")


func register_panel(panel: CCTVPanel) -> void:
	_cctv_panel = panel
	#print("[CCTVManager] Panel registered")


func on_eye_clicked(building_id: String) -> void:
	if not _cctv_panel:
		#push_warning("[CCTVManager] No panel registered")
		return
	
	# If same building clicked again close it
	if _cctv_panel.get_current_building() == building_id and _cctv_panel.visible:
		_cctv_panel.close_feed()
		return
	
	var scene_path: String = INTERIOR_SCENES.get(building_id, "")
	var building_name: String = BUILDING_NAMES.get(building_id, building_id)
	
	_cctv_panel.open_feed(building_id, building_name, scene_path)


func close() -> void:
	if _cctv_panel:
		_cctv_panel.close_feed()
