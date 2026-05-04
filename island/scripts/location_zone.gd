extends Area2D
class_name LocationZone


@export var location_data: LocationData  # Drag your .tres file here
@export var goto_scene_path:String


var entered_area=false

var location_id: String

func _ready()->void: 
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("agent"):
		print(body)
		entered_area=true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("agent"):
		print(body)
		print("exited the location", location_data)
		entered_area=false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_interact") and entered_area:
		if goto_scene_path:
			#SceneManager.switch_scene(goto_scene)
			var scene=load(goto_scene_path)
			SceneManager.switch_scene(scene)
		
	
