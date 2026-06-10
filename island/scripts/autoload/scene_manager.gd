extends Node

var current_scene:Node2D=null

func _ready()->void:
	pass
		

func switch_scene(new_scene:PackedScene):
	_deferred_switch_scene.call_deferred(new_scene)
	


func _deferred_switch_scene(new_scene:PackedScene):
	# free up the current_scene
	print("new scene ->",new_scene)
	# instantiate the new packed scene
	# load new scene 
	var game = get_tree().root.get_node("Game");
	game.load_scene(new_scene)
	
