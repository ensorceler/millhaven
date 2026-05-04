class_name CharacterStateMachine
extends Node

@export var initial_state:CharacterState
var current_state: CharacterState
var states: Dictionary = {}




func _ready() -> void:
	await owner.ready
	
	for child:CharacterState in get_children():
		states[child.name.to_lower()]=child
		child.state_machine=self
		child.character=get_parent()
		
	if initial_state:
		current_state=initial_state
		initial_state.enter()
	
	
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
	

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func change_state(new_state_name:String) -> void:
	if current_state:
		current_state.exit()
	
	print("states dict",states)
	var new_state=states[new_state_name]
	current_state=new_state
	new_state.enter()
	


func _on_agent_brain_destination_set(location_id: String) -> void:
	print("destination set in statemachine", location_id)
	change_state("walk_as_agent")




func _on_agent_brain_arrived_at_destination(location_id: String) -> void:
	change_state("idle")
	# Replace with function body.
