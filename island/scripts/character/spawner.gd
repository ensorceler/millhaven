extends Node
class_name AgentSpawner

#const AGENT = preload("res://scenes/character.tscn")

@export var AGENT_SCENE:String="res://scenes/character.tscn"

@export var current_location:String=""

var _occupancy_activity_points:Dictionary={}


var spawned_agents:Dictionary={}


func _ready()->void:
	var agent_ids=AgentStateRegistry.get_agents_at_location(current_location)
	#print("all agents at this scene", AgentStateRegistry.get_state(agents_data[0]))
	
	
	for agent_id in agent_ids:
		_spawn_agent(agent_id)
	

# Called when the node enters the scene tree for the first time.
func _spawn_agent(agent_id:String) -> void:
	
	var agent_state=AgentStateRegistry.get_state(agent_id)
	
	
	var character_data=_load_character_data(agent_id)
	if not character_data:
		return
	
	var ysort_node=get_parent().find_child("YSORT",true)
	
	if not ysort_node:
		push_warning("ysort node not found")
		return 
		
	var entry_point:Marker2D=get_parent().find_child("EntryPoint",true)
	
	var agent_scene=load(AGENT_SCENE)
	var agent:Character=agent_scene.instantiate()
	
	print("[AgentSpawner] Agent: %s -> State: %s" % [agent_id, agent_state])
	
	
	if agent_state.is_player:
		agent.type=Character.TYPE.PLAYER
		
		
	# disable camera for non player
	if not agent_state.is_player:
		var camera = agent.get_node_or_null("Camera2D")
		if camera:
			print("NOT PLAYER, CAMERA DISABLED")
			camera.enabled = false
			#agent.camera_2d.enable=false
	
	
	# assign character data (VERY IMPORTANT *******)
	agent.character_data=character_data
	
	
	if agent.agent_brain:
		agent.agent_brain.character_data=character_data
	
	
	# agent spawn properly 
	if ysort_node:
		ysort_node.add_child(agent)
		
		var portal_id = AgentStateRegistry.get_spawn_portal_id(agent_id)
		print("return portal ", portal_id)
		
		# if portal found saved, then spawn on that spot and clear the portal
		if portal_id:
			var portals=get_parent().find_children("","Portal",true)
			for portal in portals:
				if portal.portal_id==portal_id:
					print("portal found",portal)
					var return_spawn_position=portal.get_node("ReturnSpawnPoint").global_position
					agent.global_position=return_spawn_position
					AgentStateRegistry.clear_spawn_portal_id(agent_id)
		
		elif entry_point:
			agent.global_position = entry_point.global_position
			agent.agent_brain.set_location(current_location)
		
		# set the spawned agent
		spawned_agents.set(agent_id,agent)
		agent.agent_brain.despawn_agent_request.connect(_on_despawn_agent_requested)
		print("SPAWNED AGENT")


func _despawn_agent(agent_id:String) -> void:
	
	# find agent in the node tree 
	# then free that
	# delete from the _despawn map
	
	if spawned_agents.has(agent_id):
		spawned_agents[agent_id].queue_free()
		spawned_agents.erase(agent_id)
		print("[AgentSpawner: %s] has been DESPAWNED..."%agent_id)
		
	

func _load_character_data(agent_id: String) -> CharacterData:
	var path = "res://resources/character/%s.tres" % agent_id
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as CharacterData
	push_warning("[AgentSpawner] No CharacterData at: %s" % path)
	return null
	


func _on_agent_state_updated(_agent_id:String):
	var agent_ids=AgentStateRegistry.get_agents_at_location(current_location)
	
	print("[AgentSpawner]: Spawned when agent state changed -> %s" % _agent_id)
	for agent_id in agent_ids:
		if not spawned_agents.has(agent_id):
			_spawn_agent(agent_id)
			spawned_agents.set(agent_id,{})

func _on_despawn_agent_requested(agent_id):
	print("despawn agent requested...")
	print(agent_id)
	_despawn_agent(agent_id)
	
	
