class_name AgentBrain
extends Node

# ── Signals ───────────────────────────────────────────────────────────────────
# Other systems listen to these to react to agent behavior
# Animation system, UI, Rust backend will all connect to these later

signal destination_set(location_id: String)
signal arrived_at_destination(location_id: String)
signal activity_changed(activity: String)

signal despawn_agent_request(agent_id:String)
# ── Exported References ───────────────────────────────────────────────────────
# Set these in the Inspector on each agent instance

# ── Internal State ────────────────────────────────────────────────────────────

var _current_location_id: String = ""
var _current_activity: String = ""
var _target_location_id: String = ""
var _is_traveling: bool = false


var is_initialized:bool=false
# ── Node References ───────────────────────────────────────────────────────────
# Grabbed from parent character node in _ready

var _nav_agent: NavigationAgent2D
var _character_body: Character

var character_data:CharacterData=null
# ── Constants ─────────────────────────────────────────────────────────────────

const MOVE_SPEED: float = 80.0
# ── Lifecycle ─────────────────────────────────────────────────────────────────

@onready var state_machine=$"../StateMachine"


func _ready() -> void:
	if false:
		return
		
	await get_tree().process_frame
	await get_tree().process_frame
	
	
	print("READY--------- AGENTBRAIN")
	

	# Grab references from parent
	# AgentBrain sits as a child of CharacterBody2D
	_character_body = get_parent() as Character
	_nav_agent = _character_body.get_node("NavigationAgent2D")
	character_data=_character_body.character_data
	
	
	if not character_data:
		push_error("[AgentBrain] No CharacterData assigned")
		return
	
	if not character_data.schedule:
		push_error("[AgentBrain:%s] No schedule assigned" % character_data.character_id)
		return
	
	if _character_body.type==Character.TYPE.PLAYER:
		push_warning("player detected, no agent-brain is required")
		return
	
	# only connect signal after these checks
	AgentStateRegistry.agent_state_updated.connect(_on_agent_state_changed)
	
	# force tick all agents
	SimLoop.force_tick(character_data.character_id)
	_evaluate_schedule()
	
	print("[AgentBrain:%s] Ready" % character_data.character_id)


func _physics_process(_delta: float) -> void:
	# Safety check — node might have been freed during await
	if not is_inside_tree():
		return
		
	if not _is_traveling:
		return
	
	# If navigation is finished we've arrived
	if _nav_agent.is_navigation_finished():
		_on_arrived()
		return
	
	if _character_body:
		AgentStateRegistry.update_position(character_data.character_id,
		_character_body.global_position)

	
# ── Schedule Evaluation ───────────────────────────────────────────────────────
# This is the core decision function
# Called every time the clock changes time block
# Reads the schedule and kicks off movement to the right location

func _evaluate_schedule() -> void:
	
	print("[AgentBrain %s] Evaluate Schedule" % character_data.character_id)
	
	var agent_state=AgentStateRegistry.get_state(character_data.character_id)
	
	var target_location: String = agent_state.get("location")
	var target_activity: String = agent_state.get("activity")
	
	_target_location_id=target_location

	print("[AgentBrain:%s] go to '%s', do '%s'" % [
		character_data.character_id,
		target_location,
		target_activity
	])
	
	# If already at the correct location just start the activity
	# No need to travel
	print("[AgentBrain ] current location %s " % _current_location_id)
	
	# this condition is important, because if it goes to travel, it might fail for agents travelling inside the same world scene
	if _current_location_id == target_location:
		_set_activity(target_activity)
		return
	
	# Otherwise start traveling
	_travel_to(target_location, target_activity)

# ── Travel ────────────────────────────────────────────────────────────────────
# Sets the navigation target and marks agent as traveling
# The actual movement happens in _physics_process every frame

func _travel_to(location_id: String, activity_on_arrival: String) -> void:
	# Safety check — node might have been freed during await
	if not is_inside_tree():
		return
		
	# if there's no navigationregion then despawn the agent.
	if get_tree().get_nodes_in_group("nav_region").is_empty():
		# update location needed so agent state registry knows where the agent is 
		despawn_agent_request.emit(character_data.character_id)
		return
	
	_target_location_id = location_id
	_is_traveling = true
	
	# Get the world position of this location from LocationManager
	# LocationManager doesn't exist yet — we'll wire this up next
	# For now we set target_position to Vector2.ZERO as placeholder
	var world_position: Vector2 = _get_location_in_world_position(location_id)
	print("[AgentBrain] World Position: ", world_position)
	

	if world_position == Vector2.ZERO:
		push_warning("[AgentBrain:%s] Could not find position for location: %s" % [
			character_data.character_id, location_id
		])
		print("[AgentBrain:%s] Could not find position for location: %s" % [
			character_data.character_id, location_id
		])
		
		if get_exit_portal()!=Vector2.ZERO:
			print("[AgentBrain]: Exit Portal Found, Destination Set")
			_nav_agent.target_position = get_exit_portal()
			destination_set.emit(location_id)
		
		else:
			print("Exit Portal also cannot be found, no travelling")
			# this can be despawned automatically
			_is_traveling = false
			return
	
	# if world_position is found 
	else:	
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

	_character_body.velocity = Vector2.ZERO
	
	arrived_at_destination.emit(_current_location_id)
	print("[AgentBrain:%s] Arrived at '%s'" % [
		character_data.character_id, _current_location_id
	])
	


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
	
	_go_to_activity_point(activity)

# ── Location Position Resolver ────────────────────────────────────────────────
# This is the one missing piece — getting world position from location ID
# Right now returns Vector2.ZERO as placeholder
# Will be replaced when LocationManager exists

func _get_location_position(location_id: String) -> Vector2:
	# when LocationManager is built
	return LocationManager.get_location(location_id)

# find if the location even actually exits in the current scene oherwise return vector zero
func _get_location_in_world_position(location_id:String) ->Vector2:
	# can get from spawner
	var agent_spawner=get_tree().get_first_node_in_group("agent_spawner")
	if not agent_spawner:
		push_error("[AgentBrain] AgentSpawner Not Found in group")
		print("[AgentBrain] AgentSpawner Not Found in group")
		return Vector2.ZERO
	
	#print("[AgentBrain]: agent_spawner -> ", agent_spawner)
	var world_id=agent_spawner.current_location
	
	return LocationManager.get_location_in_world(world_id,location_id)
	
# ── Clock Signal Handler ──────────────────────────────────────────────────────

# not using any parameter for now
func _on_agent_state_changed(_agent_id, _agent_state) -> void:
	if _agent_id!=character_data.character_id:
		return
	_evaluate_schedule()


# ── Public API ────────────────────────────────────────────────────────────────
# These are what other systems call to query agent state

func get_current_location() -> String:
	return _current_location_id

func set_location(location_id:String):
	_current_location_id=location_id

func get_current_activity() -> String:
	return _current_activity

func is_traveling() -> bool:
	return _is_traveling

func get_agent_id() -> String:
	if character_data:
		return character_data.character_id
	return "unknown"

func _go_to_activity_point(activity:String):
	var activity_points=get_tree().get_nodes_in_group("activity_point")
	print("activity points", activity_points)
	
	var target_activity_point:ActivityPoint=null
	var is_activity_found=false
	
	for activity_point:ActivityPoint in activity_points:
		if activity_point.activity==activity:
			print("[AgentBrain] Found the activity and setting it")
			is_activity_found=true
			target_activity_point=activity_point
			
	# check for default activity(if nothing is found)
	if not is_activity_found:
		for act_point in activity_points:
			if act_point.activity=="default":
				target_activity_point=act_point
			
		
	# travel logic to activity point if navigation_region is there. 
	if get_tree().get_nodes_in_group("nav_region"):
		if is_initialized:	
			print("[AgentBrain: %s]: player travelling "%character_data.character_id)
			_is_traveling=true 
			_nav_agent.target_position=target_activity_point.global_position
			destination_set.emit(_target_location_id)
		else:
			is_initialized=true
			print("[AgentBrain: %s]: player activity set directly instead of travelling "%character_data.character_id)
			_character_body.set_player_activity(target_activity_point.global_position,
		target_activity_point.character_animation,
		target_activity_point.character_face_direction
		)
		

	else:
		# else set it directly
		print("[AgentBrain: %s]: SET directly because navigation lacking "%character_data.character_id)
		_character_body.set_player_activity(target_activity_point.global_position,
		target_activity_point.character_animation,
		target_activity_point.character_face_direction
		)
	



func get_exit_portal() -> Vector2:
	
	var portals=get_tree().get_nodes_in_group("portal")
	print("[AgentBrain]: portals -> ", portals)
	if len(portals):
		for portal:Portal in portals:
			if portal.exit_portal:
				return portal.global_position
			else:
				return Vector2.ZERO
	
	return Vector2.ZERO
