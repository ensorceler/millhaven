extends Node2D
class_name ActivityPoint

@export var activity:String;
@export var character_animation:String;
@export var character_face_direction:String;

var entered_body:Character=null

@onready var marker=$Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("agent"):
		entered_body=body
		
		entered_body.set_player_activity(marker.global_position,
			character_animation,
			character_face_direction
		)
	
		
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("agent"):
		entered_body=null
		print("exited body agent",body)
