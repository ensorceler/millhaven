extends Node

# keeps track of all the agent state 
# ── The Registry ──────────────────────────────────────────────────────────────
# Holds live state for every agent keyed by character_id
# Example entry:
# "john" → {
#     "location": "windmill",
#     "activity": "working",
#     "position": Vector2(300, 200),
#     "is_traveling": false,
#     "time_block": "morning",
#     "day": 1,
# }

var _states: Dictionary = {}

func _ready() -> void:

	_states["elena"]={
	 "location": "island",
	 "activity": "nothing",
	 "position": Vector2(300, 200),
	 "is_traveling": false,
	 "time_block": "morning",
	 "day": 1,
	 "is_player":false,
	}

	_states["john"]={
	 "location": "island",
	 "activity": "nothing",
	 "position": Vector2(302, 205),
	 "is_traveling": false,
	 "time_block": "morning",
	 "day": 1,
	 "is_player":false,
	}
	
	_states["thomas"]={
	 "location": "island",
	 "activity": "idle",
	 "position": Vector2(302, 205),
	 "is_traveling": false,
	 "time_block": "morning",
	 "day": 1,
	 "is_player":true,
	}
# ── Signals ───────────────────────────────────────────────────────────────────

# Fires whenever any agent's state changes
signal agent_state_updated(agent_id: String, state: Dictionary)

# ── Write ─────────────────────────────────────────────────────────────────────
# Called by AgentBrain every time something changes

func update_state(agent_id: String, state: Dictionary) -> void:
	_states[agent_id] = state
	agent_state_updated.emit(agent_id, state)


func update_position(agent_id: String, position: Vector2) -> void:
	if not _states.has(agent_id):
		_states[agent_id] = {}
	_states[agent_id]["position"] = position


func update_activity(agent_id: String, activity: String) -> void:
	if not _states.has(agent_id):
		_states[agent_id] = {}
	_states[agent_id]["activity"] = activity
	agent_state_updated.emit(agent_id, _states[agent_id])


func update_location(agent_id: String, location_id: String) -> void:
	if not _states.has(agent_id):
		_states[agent_id] = {}
	_states[agent_id]["location"] = location_id
	agent_state_updated.emit(agent_id, _states[agent_id])

# ── Read ──────────────────────────────────────────────────────────────────────
# Called by interior spawner and any system that needs agent state

func get_state(agent_id: String) -> Dictionary:
	return _states.get(agent_id, {})


func get_all_states() -> Dictionary:
	return _states.duplicate()


func get_agents_at_location(location_id: String) -> Array:
	var result: Array = []
	for agent_id in _states:
		if _states[agent_id].get("location", "") == location_id:
			result.append(agent_id)
	return result


func get_activity(agent_id: String) -> String:
	return _states.get(agent_id, {}).get("activity", "idle")


func get_location(agent_id: String) -> String:
	return _states.get(agent_id, {}).get("location", "")


func get_position(agent_id: String) -> Vector2:
	return _states.get(agent_id, {}).get("position", Vector2.ZERO)


func is_registered(agent_id: String) -> bool:
	return _states.has(agent_id)

# ── Debug ─────────────────────────────────────────────────────────────────────

func print_all_states() -> void:
	print("[AgentStateRegistry] Current states:")
	for agent_id in _states:
		print("  %s → %s" % [agent_id, _states[agent_id]])


func set_spawn_portal_id(agent_id: String, portal_id:String) -> void:
	if not _states.has(agent_id):
		_states[agent_id] = {}
	_states[agent_id]["spawn_portal_id"] = portal_id


func get_spawn_portal_id(agent_id: String) -> String:
	return _states.get(agent_id, {}).get("spawn_portal_id", "")


func clear_spawn_portal_id(agent_id: String) -> void:
	if _states.has(agent_id):
		_states[agent_id].erase("spawn_portal_id")
	
	
