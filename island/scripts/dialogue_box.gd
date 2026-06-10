extends Control
class_name DialogueBox

@onready var close_button: TextureButton = $HFlowContainer/DialogueBoxBackground/MarginContainer/MainContainer/VBoxContainer/VBoxContainer/CloseButton
@onready var agent_name: Label = $HFlowContainer/DialogueBoxBackground/MarginContainer/MainContainer/AgentInformationContainer/AgentName


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_close_button_pressed() -> void:
	Eventbus.dialogue_closed.emit()
	
