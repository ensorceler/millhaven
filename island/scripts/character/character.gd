class_name Character
extends CharacterBody2D

enum TYPE{
	AGENT,
	PLAYER
}

var SPEED = 50.0
@export var character_data:CharacterData;
@export var type:TYPE=TYPE.AGENT

var flip=false
var face_direction:String="front"
var _last_time: String = ""


@onready var body_animation: AnimatedSprite2D = $Body
@onready var state_machine:CharacterStateMachine=$StateMachine;
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var body: AnimatedSprite2D = $Body
@onready var hair: AnimatedSprite2D = $Hair
@onready var clothing: AnimatedSprite2D = $Clothing
@onready var display_name: Label = $CanvasLayer/Label

# agent brain
@onready var agent_brain: AgentBrain = $AgentBrain

# camera 
@onready var camera_2d: Camera2D = $Camera2D


func _init():
	pass

func _ready() -> void:
	# Test 1: Send hello
	#await get_tree().create_timer(1.0).timeout
	#ApiClient.get_hello()
	#agent_brain.process_mode=Node.PROCESS_MODE_DISABLED
	#remove_child(agent_brain)
	_load_character_sprite()
	
	
	if type == TYPE.PLAYER:
		camera_2d.enabled = true
		camera_2d.make_current()
		display_name.visible=false
	else:
		SPEED=character_data.speed
		display_name.text=character_data.character_name
		camera_2d.enabled = false
	
	

func _process(delta: float) -> void:
	display_name.global_position=Vector2(global_position.x-10,global_position.y-24)

func play_animation(action:String):
	body.play(action+"_"+face_direction)
	hair.play(action+"_"+face_direction)
	clothing.play(action+"_"+face_direction)
	
	
	
func _load_character_sprite():
	body.sprite_frames=character_data.sprite_body
	hair.sprite_frames=character_data.sprite_hair
	clothing.sprite_frames=character_data.sprite_clothing
	# add accessory later
	
	
func set_player_activity(position:Vector2i,action:String,direction:String):
	face_direction=direction
	state_machine.change_state(action)
	#play_animation(action)
	global_position=position
	
	
