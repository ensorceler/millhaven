extends CharacterState
class_name CharacterWalkState 



func enter()->void: 
	character.play_animation("walk")
	#print("enter walk")
	
func exit()->void: 
	#print("exit walk")
	pass

func physics_update(delta:float)->void:
	
	if character.type!=Character.TYPE.PLAYER:
		print("[AGENT TRYING TO WALK]")
		return
		
	var direction=Vector2.ZERO
	
	if Input.is_action_pressed("left"):
		direction.x-=1
		character.face_direction="left"
		
	if Input.is_action_pressed("right"):
		direction.x+=1
		character.face_direction="right"

	if Input.is_action_pressed("front"):
		direction.y+=1
		character.face_direction="front"

	if Input.is_action_pressed("back"):
		direction.y-=1
		character.face_direction="back"

	character.play_animation("walk")
	
	if direction.length()>0:
		direction=direction.normalized()
		character.velocity=direction*character.SPEED
		character.move_and_slide()
	else: 
		character.velocity=Vector2.ZERO
		state_machine.change_state("idle")
