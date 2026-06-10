extends CanvasLayer


@onready var time_label: Label = $StatusBar/NinePatchRect/MarginContainer/UserDetailContainer/VBoxContainer/HBoxContainer/TimeLabel

@onready var dialogue_box: DialogueBox = $DialogueBox

@onready var interaction_message_label: Label = $InteractionAlert/Container/NinePatchRect/InteractionMessageLabel

@onready var interaction_alert: Control = $InteractionAlert


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_box.visible=false
	interaction_alert.visible=false
	
	
	Eventbus.interaction_alert.connect(_on_interaction_alert)
	Eventbus.dialogue_requested.connect(_on_dialogue_requested)
	Eventbus.dialogue_closed.connect(_on_dialogue_closed)

	Eventbus.scene_changed.connect(_on_scene_changed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_label.text=SimulationClock.get_time_string()



func _on_interaction_alert(visible:bool,message:String):
	#print("[HUD] interaction_alert called with visible=%s stack=%s" % [visible, get_stack()])
	if message:
		interaction_message_label.text=message
	
	# ON and OFF
	interaction_alert.visible=visible


func _on_dialogue_requested(agent_data:CharacterData):
	SimulationClock.pause()
	dialogue_box.agent_name.text=agent_data.character_name.to_upper()
	dialogue_box.visible=true
	
	
	
func _on_dialogue_closed():
	dialogue_box.visible=false
	dialogue_box.agent_name.text="NA"
	SimulationClock.resume()
	
	
func _on_scene_changed():
	#dialogue_box.visible=false
	interaction_alert.visible=false
	
