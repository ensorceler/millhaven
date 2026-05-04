class_name AgentBrain
extends Node

# ── Signals ───────────────────────────────────────────────────────────────────
# Other systems listen to these to react to agent behavior
# Animation system, UI, Rust backend will all connect to these later

signal destination_set(location_id: String)
signal arrived_at_destination(location_id: String)
signal activity_changed(activity: String)

# ── Exported References ───────────────────────────────────────────────────────
# Set these in the Inspector on each agent instance

# The character's data resource — contains id, name, schedule reference
@export var character_data: CharacterData

# ── Internal State ────────────────────────────────────────────────────────────

var _current_location_id: String = ""
var _current_activity: String = "idle"
var _target_location_id: String = ""
var _is_traveling: bool = false

# ── Node References ───────────────────────────────────────────────────────────
# Grabbed from parent character node in _ready

var _nav_agent: NavigationAgent2D
var _character_body: CharacterBody2D

# ── Constants ─────────────────────────────────────────────────────────────────

const MOVE_SPEED: float = 80.0

# ── Lifecycle ─────────────────────────────────────────────────────────────────

@onready var state_machine=$"../StateMachine"


func _ready() -> void:
	
	await get_tree().process_frame
	await get_tree().process_frame
	print("READY--------- AGENTBRAIN")
	# Grab references from parent
	# AgentBrain sits as a child of CharacterBody2D
	_character_body = get_parent() as Character
	_nav_agent = _character_body.get_node("NavigationAgent2D")
	
	if not character_data:
		push_warning("[AgentBrain] No CharacterData assigned")
		return
	
	if not character_data.schedule:
		push_warning("[AgentBrain:%s] No schedule assigned" % character_data.character_id)
		return
	
	# Connect to the simulation clock
	SimulationClock.time_block_changed.connect(_on_time_block_changed)
	
	# Evaluate immediately so agent starts doing something on game launch
	# rather than standing still until the first time block transition
	var current_block: String = SimulationClock.get_block_name()
	_evaluate_schedule(current_block)
	
	print("[AgentBrain:%s] Ready" % character_data.character_id)

func _physics_process(_delta: float) -> void:
	if not _is_traveling:
		return
	
	# If navigation is finished we've arrived
	if _nav_agent.is_navigation_finished():
		_on_arrived()
		return
	
	# Move toward next point on the navigation path
	'''
	var next_point: Vector2 = _nav_agent.get_next_path_position()
	var direction: Vector2 = (next_point - _character_body.global_position).normalized()
	_character_body.velocity = direction * MOVE_SPEED
	_character_body.move_and_slide()
	'''
	
# ── Schedule Evaluation ───────────────────────────────────────────────────────
# This is the core decision function
# Called every time the clock changes time block
# Reads the schedule and kicks off movement to the right location

func _evaluate_schedule(block_name: String) -> void:
	var schedule: AgentSchedule = character_data.schedule
	
	var target_location: String = schedule.get_location(block_name)
	var target_activity: String = schedule.get_activity(block_name)
	
	if target_location.is_empty():
		push_warning("[AgentBrain:%s] No location for block: %s" % [
			character_data.character_id, block_name
		])
		return
	
	print("[AgentBrain:%s] Block '%s' → go to '%s', do '%s'" % [
		character_data.character_id,
		block_name,
		target_location,
		target_activity
	])
	
	# If already at the correct location just start the activity
	# No need to travel
	if _current_location_id == target_location:
		_set_activity(target_activity)
		return
	
	# Otherwise start traveling
	_travel_to(target_location, target_activity)

# ── Travel ────────────────────────────────────────────────────────────────────
# Sets the navigation target and marks agent as traveling
# The actual movement happens in _physics_process every frame

func _travel_to(location_id: String, activity_on_arrival: String) -> void:
	_target_location_id = location_id
	_is_traveling = true
	
	# Get the world position of this location from LocationManager
	# LocationManager doesn't exist yet — we'll wire this up next
	# For now we set target_position to Vector2.ZERO as placeholder
	var world_position: Vector2 = _get_location_position(location_id)
	
	if world_position == Vector2.ZERO:
		push_warning("[AgentBrain:%s] Could not find position for location: %s" % [
			character_data.character_id, location_id
		])
		_is_traveling = false
		return
	
	_nav_agent.target_position = world_position
	destination_set.emit(location_id)
	
	print("[AgentBrain:%s] Traveling to '%s'" % [
		character_data.character_id, location_id
	])

# ── Arrival ───────────────────────────────────────────────────────────────────
# Called when NavigationAgent2D reports navigation is finished

func _on_arrived() -> void:
	_is_traveling = false
	_current_location_id = _target_location_id
	_target_location_id = ""
	_character_body.velocity = Vector2.ZERO
	
	arrived_at_destination.emit(_current_location_id)
	print("[AgentBrain:%s] Arrived at '%s'" % [
		character_data.character_id, _current_location_id
	])
	
	# Now start the scheduled activity at this location
	# Get activity from current block's schedule
	var block_name: String = SimulationClock.get_block_name()
	var activity: String = character_data.schedule.get_activity(block_name)
	_set_activity(activity)

# ── Activity ──────────────────────────────────────────────────────────────────
# Sets the current activity and emits signal
# Animation system will react to this signal later

func _set_activity(activity: String) -> void:
	if _current_activity == activity:
		return
	
	_current_activity = activity
	activity_changed.emit(activity)
	
	print("[AgentBrain:%s] Activity → '%s'" % [
		character_data.character_id, activity
	])

# ── Location Position Resolver ────────────────────────────────────────────────
# This is the one missing piece — getting world position from location ID
# Right now returns Vector2.ZERO as placeholder
# Will be replaced when LocationManager exists

func _get_location_position(location_id: String) -> Vector2:
	# when LocationManager is built
	return LocationManager.get_location(location_id)
	
	
# ── Clock Signal Handler ──────────────────────────────────────────────────────

func _on_time_block_changed(
	_old_block: SimulationClock.TimeBlock,
	new_block: SimulationClock.TimeBlock
) -> void:
	var block_name: String = SimulationClock.get_block_name(new_block)
	_evaluate_schedule(block_name)

# ── Public API ────────────────────────────────────────────────────────────────
# These are what other systems call to query agent state

func get_current_location() -> String:
	return _current_location_id

func get_current_activity() -> String:
	return _current_activity

func is_traveling() -> bool:
	return _is_traveling

func get_agent_id() -> String:
	if character_data:
		return character_data.character_id
	return "unknown"

# ── Future Hook For Rust Backend ──────────────────────────────────────────────
# When Rust sends a decision, call this instead of _evaluate_schedule
# Everything else stays identical — only the input source changes

func receive_backend_instruction(location_id: String, activity: String) -> void:
	# TODO: Wire to Rust /state response handler
	# This completely replaces _evaluate_schedule when backend is ready
	print("[AgentBrain:%s] Backend instruction → %s, %s" % [
		character_data.character_id, location_id, activity
	])
	if _current_location_id != location_id:
		_travel_to(location_id, activity)
	else:
		_set_activity(activity)
