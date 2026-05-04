extends Node

var current_scene:Node2D=null

func _ready()->void:	
	current_scene=get_tree().get_first_node_in_group("island_map")
	if current_scene:
		print("current scene ->", current_scene.name)
		
		
func switch_scene(new_scene:PackedScene):
	_deferred_switch_scene.call_deferred(new_scene)
	
	
func _deferred_switch_scene(new_scene:PackedScene):
	# free up the current_scene
	current_scene.free()
	
	print("new scene ->",new_scene)
	# instantiate the new packed scene
	var new_active_scene=new_scene.instantiate()

	get_tree().root.add_child(new_active_scene)
	#assign the current_scene
	current_scene=new_active_scene
	# main scene change
	get_tree().current_scene=new_active_scene
	
	

	
