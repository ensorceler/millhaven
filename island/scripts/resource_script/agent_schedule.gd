class_name AgentSchedule
extends Resource

# ── Morning ───────────────────────────────────────────────────────────────────
@export var morning_location: String = ""
@export var morning_activity: String = ""

# ── Noon ──────────────────────────────────────────────────────────────────────
@export var noon_location: String = ""
@export var noon_activity: String = ""

# ── Afternoon ─────────────────────────────────────────────────────────────────
@export var afternoon_location: String = ""
@export var afternoon_activity: String = ""

# ── Evening ───────────────────────────────────────────────────────────────────
@export var evening_location: String = ""
@export var evening_activity: String = ""

# ── Night ─────────────────────────────────────────────────────────────────────
@export var night_location: String = ""
@export var night_activity: String = ""

# ── Helper ────────────────────────────────────────────────────────────────────

func get_location(block_name: String) -> String:
	match block_name:
		"morning":   return morning_location
		"noon":      return noon_location
		"afternoon": return afternoon_location
		"evening":   return evening_location
		"night":     return night_location
	return ""

func get_activity(block_name: String) -> String:
	match block_name:
		"morning":   return morning_activity
		"noon":      return noon_activity
		"afternoon": return afternoon_activity
		"evening":   return evening_activity
		"night":     return night_activity
	return "idle"
	
	
