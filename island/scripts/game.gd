extends Node2D
class_name GameScene

@export var main_scene:PackedScene;

var _current_scene=null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_scene(main_scene)


func load_scene(scene:PackedScene)->void:
	# free up the scene 
	if _current_scene:
		_current_scene.free()
		
	# instantiate the new scene
	var active_scene=scene.instantiate()
	# this is the game scene so only add child also works
	# add_child(active_scene)
	add_child(active_scene)
	#assign the current_scene
	_current_scene=active_scene
	
	#get_tree().current_scene=active_scene
	
	Eventbus.scene_changed.emit()
