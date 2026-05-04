extends Node
class_name AgentSpawner

const AGENT = preload("res://scenes/character.tscn")


func _ready()->void:
	_spawn_agent()

# Called when the node enters the scene tree for the first time.
func _spawn_agent() -> void:
	
	var ysort_node=get_parent().find_child("YSORT",true)
	var entry_point:Marker2D=get_parent().find_child("EntryPoint",true)
	
	var agent=AGENT.instantiate()
	
	if ysort_node:
		#print("ysort ->",ysort_node)
		ysort_node.add_child(agent)
		agent.global_position=entry_point.global_position
		print("SPAWNED AGENT")
