extends Node

const VALID_STATES=["idle", "sit", "check_smartphone"]

var _is_player_detected=false
var _is_dialog_request_valid=false
# player who's trying to interact
var _player_detected:Character=null
# agent whom the player is interacting with
var _agent_interacted:Character=null

# is_ready there to just wait for few frames. 
var _is_ready=false


func _ready() -> void:
		# Wait two frames before enabling detection
	# Prevents false triggers on scene load spawn overlap
	await get_tree().process_frame
	await get_tree().process_frame
	
	_is_ready=true


func _on_body_entered(body: Node2D) -> void:
	if not _is_ready:
		return
		
	if body.is_in_group("agent"):
		var char:Character=body
		if char.type==Character.TYPE.PLAYER:
			_is_player_detected=true
			_player_detected=char
			
			# check the parent of the dialogue-detector node 
			#print("[DialogueDetection] agent state",agent.state_machine.current_state)
			var agent:Character=get_parent()
			var agent_state=agent.state_machine.current_state.name.to_lower()
			_agent_interacted=agent
			
			print("[DialogueDetection] agent state->",agent_state)
			if VALID_STATES.has(agent_state):
				_is_dialog_request_valid=true
				Eventbus.interaction_alert.emit(true,"")
				print("[DialogueDetection] agent state valid")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("agent"):
		var char:Character=body
		if char.type==Character.TYPE.PLAYER:
			_is_player_detected=false
			_player_detected=null
			_agent_interacted=null
			_is_dialog_request_valid=false
			Eventbus.interaction_alert.emit(false,"")
			print("[DialogueDetection] Player Exited")
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _is_dialog_request_valid:
		Eventbus.interaction_alert.emit(false,"")
		Eventbus.dialogue_requested.emit(_agent_interacted.character_data)
