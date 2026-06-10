extends Node2D

var is_hovered=false

@onready var click_area: Area2D = $ClickArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_click_area_mouse_entered() -> void:
	print("enter hover on eye")
	is_hovered=true


func _on_click_area_mouse_exited() -> void:
	print("exit hover on eye")
	is_hovered=false



func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_hovered and event.is_action_pressed("left_click"):
		print("<- eye clicked ->")
		CCTVManager.on_eye_clicked("tavern")
