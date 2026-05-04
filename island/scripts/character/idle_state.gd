extends CharacterState
class_name CharacterIdleState 


@onready var agent_brain:AgentBrain=$"../../AgentBrain"


func enter():
	character.play_animation("idle")
	print("idle")


func physics_update(delta: float) -> void:
	'''
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right") || Input.is_action_just_pressed("front") || Input.is_action_just_pressed("back"):
		state_machine.change_state("walk")
	'''
	pass

func handle_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right") || Input.is_action_just_pressed("front") || Input.is_action_just_pressed("back"):
		state_machine.change_state("walk")
		
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click"):
			var target = character.get_global_mouse_position()
			character.nav_agent.target_position = target
			state_machine.change_state("walk_as_agent")
			
			
