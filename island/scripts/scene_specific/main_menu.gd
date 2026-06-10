extends Node2D
class_name MainMenu

@onready var new_game: TextureButton = $UI/MenuContainer/HBoxContainer/HBoxContainer/NewGame
@onready var load: TextureButton = $UI/MenuContainer/HBoxContainer/HBoxContainer/Load
@onready var co_op: TextureButton = $"UI/MenuContainer/HBoxContainer/HBoxContainer/Co-OP"
@onready var exit_game: TextureButton = $UI/MenuContainer/HBoxContainer/HBoxContainer/Exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game.pressed.connect(_on_pressed_new_game)
	exit_game.pressed.connect(_on_exit_game)
	_setup_hover(new_game)
	_setup_hover(load)
	_setup_hover(co_op)
	_setup_hover(exit_game)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_pressed_new_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	

func _on_exit_game():
	get_tree().quit()
	

func _setup_hover(btn: TextureButton) -> void:
	btn.mouse_entered.connect(func(): btn.modulate = Color(1.3, 1.15, 0.85))
	btn.mouse_exited.connect(func(): btn.modulate = Color.WHITE)
	
