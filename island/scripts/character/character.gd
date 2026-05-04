class_name Character
extends CharacterBody2D


const SPEED = 50.0
var flip=false

var face_direction:String="front"
var _last_time: String = ""

@onready var body_animation: AnimatedSprite2D = $Body
@onready var state_machine:CharacterStateMachine;
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var body: AnimatedSprite2D = $Body
@onready var hair: AnimatedSprite2D = $Hair
@onready var clothing: AnimatedSprite2D = $Clothing

# agent brain
@onready var agent_brain: AgentBrain = $AgentBrain


func _init():
	pass

func _ready() -> void:
	# Test 1: Send hello
	#await get_tree().create_timer(1.0).timeout
	#ApiClient.get_hello()
	pass

func _process(delta: float) -> void:
	var current = SimulationClock.get_time_string()
	if current != _last_time:
		_last_time = current
		print(current)

func play_animation(action:String):
	body.play(action+"_"+face_direction)
	hair.play(action+"_"+face_direction)
	clothing.play(action+"_"+face_direction)
	pass
