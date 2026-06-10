extends CharacterState
class_name CharacterIdleState 


@onready var agent_brain:AgentBrain=$"../../AgentBrain"


func enter():
	character.play_animation("idle")

func exit():
	pass

func physics_update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	
	if (character.type==Character.TYPE.PLAYER ) and (Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right") || Input.is_action_just_pressed("front") || Input.is_action_just_pressed("back")):
		state_machine.change_state("walk")
		
	if event is InputEventMouseButton:
		if (character.type==Character.TYPE.PLAYER ) and Input.is_action_just_pressed("right_click"):
			var target = character.get_global_mouse_position()
			character.nav_agent.target_position = target
			state_machine.change_state("walk_as_agent")
		
	if event is InputEventKey:
		if (character.type==Character.TYPE.PLAYER ) and event.keycode == KEY_R and event.pressed:
			AgentStateRegistry.print_all_states()
	
	if event is InputEventKey:
		if (character.type==Character.TYPE.PLAYER ) and event.keycode == KEY_F and event.pressed:
			state_machine.change_state("check_smartphone")	
