extends Node
# SimLoop
# ── Internal ──────────────────────────────────────────────────────────────────

# Holds all registered agent schedules keyed by character_id
# { "john": AgentSchedule, "elena": AgentSchedule, ... }
var _agent_schedules: Dictionary = {}

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Load all character resources and register their schedules
	_load_all_agents()
	
	# Listen to simulation clock
	SimulationClock.time_block_changed.connect(_on_time_block_changed)
	SimulationClock.day_changed.connect(_on_day_changed)
	
	print("[SimulationLoop] Ready — %d agents registered" % _agent_schedules.size())
	
	

func _load_all_agents() -> void:
	
 	# load the agents from agentstateregistry
	var agent_states=AgentStateRegistry.get_all_states()
	var char_data=null

	
	for agent_id in agent_states:
		var path = "res://resources/character/%s.tres" % agent_id
		if ResourceLoader.exists(path):
			char_data=ResourceLoader.load(path) as CharacterData
			_register_agent(char_data)
		else:
			push_error("character data NOT FOUND for agent %s" %agent_id)
	

func _register_agent(char_data: CharacterData) -> void:
	

	if not char_data.schedule:
		push_warning("[SimulationLoop] %s has no schedule" % char_data.character_id)
		return
	
	_agent_schedules[char_data.character_id] = char_data.schedule

	# Initialize registry state if not already set
	# This handles first boot — agent has never been registered
	if not AgentStateRegistry.is_registered(char_data.character_id):
		AgentStateRegistry.update_state(char_data.character_id, {
			"location": char_data.starting_location_id,
			"activity": "idle",
			"position": Vector2.ZERO,
			"is_traveling": false,
			"time_block": SimulationClock.get_block_name(),
			"day": SimulationClock.get_day(),
			"is_player": false,
		})
		push_warning("[SimulationLoop] Registered agent: %s at %s" % [
			char_data.character_id,
			char_data.starting_location_id
		])

# ── Simulation Tick ───────────────────────────────────────────────────────────

func _tick_all_agents(block_name: String) -> void:
	for agent_id in _agent_schedules:
		_tick_agent(agent_id, block_name)


func _tick_agent(agent_id: String, block_name: String) -> void:
	var schedule: AgentSchedule = _agent_schedules[agent_id]
	
	var target_location: String = schedule.get_location(block_name)
	var target_activity: String = schedule.get_activity(block_name)
	
	if target_location.is_empty():
		return
	
	# Update registry with new target location and activity
	# AgentBrain will react to this if it's running
	AgentStateRegistry.update_location(agent_id, target_location)
	AgentStateRegistry.update_activity(agent_id, target_activity)
	
	# Update time context
	var state = AgentStateRegistry.get_state(agent_id)
	state["time_block"] = block_name
	state["day"] = SimulationClock.get_day()
	AgentStateRegistry.update_state(agent_id, state)
	
	print("[SimulationLoop] SET %s → location: %s, activity: %s" % [
		agent_id, target_location, target_activity
	])

# ── Clock Handlers ────────────────────────────────────────────────────────────

func _on_time_block_changed(
	_old: SimulationClock.TimeBlock,
	new_block: SimulationClock.TimeBlock
) -> void:
	var block_name = SimulationClock.get_block_name(new_block)
	print("[SimulationLoop] Time block changed to: %s" % block_name)
	_tick_all_agents(block_name)


func _on_day_changed(day: int) -> void:
	print("[SimulationLoop] New day: %d" % day)
	# Hook for future LLM daily planning
	# For now just tick with current block
	_tick_all_agents(SimulationClock.get_block_name())

# ── Public API ────────────────────────────────────────────────────────────────

func get_registered_agents() -> Array:
	return _agent_schedules.keys()


func is_agent_registered(agent_id: String) -> bool:
	return _agent_schedules.has(agent_id)


func force_tick(agent_id: String) -> void:
	# Force a single agent to re-evaluate their schedule
	# Useful when spawning an agent mid-simulation
	var block_name = SimulationClock.get_block_name()
	_tick_agent(agent_id, block_name)
	
func force_tick_all_agents()->void:
	var block_name = SimulationClock.get_block_name()
	_tick_all_agents(block_name)
	
	
