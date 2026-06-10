extends Node2D
'''
@onready var cctv_panel=$CanvasLayer/CCTVPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CCTVManager.register_panel(cctv_panel)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

'''
