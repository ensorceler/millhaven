extends CharacterState
class_name CharacterWalkAsAgentState



func enter()->void:
	character.play_animation("walk")
	print("enter walk")
	
func exit()->void:
	print("exit walk")

func physics_update(delta:float)->void:
	
	if character.nav_agent.is_navigation_finished():
		state_machine.change_state("idle")
		return
		
	var next_pos = character.nav_agent.get_next_path_position()
	var direction = (next_pos - character.global_position).normalized()
	
	if abs(direction.x) > abs(direction.y):
		# moving more horizontally
		if direction.x > 0:
			character.face_direction="right"
		else:
			character.face_direction="left"
	else:
		# moving more vertically
		if direction.y > 0:
			character.face_direction="front"
		else:
			character.face_direction="back"
	
	character.play_animation("walk")
	character.velocity = direction * character.SPEED
	character.move_and_slide()

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("right_click"):
			var target = character.get_global_mouse_position()
			character.nav_agent.target_position = target


	
