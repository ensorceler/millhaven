class_name CharacterState
extends Node

# Reference to the state machine
var state_machine:CharacterStateMachine = null
var character: Character=null


func _init() -> void:
	print("init method in state",self)

# Called when entering the state
func enter() -> void:
	pass

# Called when exiting the state
func exit() -> void:
	pass

# Called every frame
func update(delta: float) -> void:
	pass

# Called every physics frame
func physics_update(delta: float) -> void:
	pass

# Handle input events
func handle_input(event: InputEvent) -> void:
	pass
	
	
