extends Area2D
class_name LocationZone


#@export var location_data: LocationData  # Drag your .tres file here
@export var goto_scene_path:String;
@export var enter_location_id:String;

var entered_area=false

var entered_body:Character=null
#var location_id: String

func _ready()->void: 
	pass


func _on_body_entered(body: Node2D) -> void:
	print("body entered",body)
	if body.is_in_group("agent"):
		print("AGENT ENTERED",body)
		# call to enter agent, which despawns the agent from that scene
		var agent:Character=body
		
		entered_body=body
		entered_area=true
		
		if agent.type==Character.TYPE.AGENT:
			print("AGENT TYPE")
			AgentStateRegistry.update_location(agent.character_data.character_id,
			enter_location_id)
			agent.get_parent().remove_child(agent)
			agent.queue_free()
			return

		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("agent"):
		#print(body)
		print("exited the location")
		entered_area=false
		entered_body=null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and entered_area:
		# only for player entry
		print("player interact with ",enter_location_id)
		print("entered_body", entered_body)
		if goto_scene_path and entered_body.type==Character.TYPE.PLAYER:
			var scene=load(goto_scene_path)
			# update agent stateregistry
			AgentStateRegistry.update_location(entered_body.character_data.character_id,
			enter_location_id)
			
			SceneManager.switch_scene(scene)
