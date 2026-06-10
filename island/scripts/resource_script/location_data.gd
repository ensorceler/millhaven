extends Resource
class_name LocationData

# ── Identity ──────────────────────────────────────────────
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""

# ── World Position ─────────────────────────────────────────
@export var world_scene:String=""
@export var zone: String = ""
@export var center_tile: Vector2i = Vector2i.ZERO
@export var entry_tile: Vector2i = Vector2i.ZERO

# ── Simulation Data ────────────────────────────────────────
@export var activities: Array[String] = []
@export var adjacent_ids: Array[String] = []
@export var max_occupancy: int = 4

# ── Time Access ────────────────────────────────────────────
@export var open_hours: Array[String] = []

# ── Interaction Points ─────────────────────
# key = point name (e.g. "desk", "bed", "counter")
# value = tile coordinate as Vector2i
@export var interaction_points: Dictionary = {}

# ── LLM Context ────────────────────────────────────────────
# personality types drawn to this location
@export var agent_affinity: Array[String] = []

# ── Helper Functions ───────────────────────────────────────

func is_open(time_of_day: String) -> bool:
	if open_hours.is_empty():
		return true
	return time_of_day in open_hours


func has_capacity(current_count: int) -> bool:
	return current_count < max_occupancy


func get_interaction_tile(point_name: String) -> Vector2i:
	if interaction_points.has(point_name):
		return interaction_points[point_name]
	return entry_tile

func get_entry_position() -> Vector2i:
	return entry_tile

func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"description": description,
		"zone": zone,
		"center_tile": [center_tile.x, center_tile.y],
		"entry_tile": [entry_tile.x, entry_tile.y],
		"activities": activities,
		"adjacent_ids": adjacent_ids,
		"max_occupancy": max_occupancy,
		"open_hours": open_hours,
		"interaction_points": _serialize_interaction_points(),
		"agent_affinity": agent_affinity,
	}


func get_id()->String:
	return id


func _serialize_interaction_points() -> Dictionary:
	var result: Dictionary = {}
	for key in interaction_points:
		var tile: Vector2i = interaction_points[key]
		result[key] = [tile.x, tile.y]
	return result
