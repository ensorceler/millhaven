extends Control
class_name CCTVPanel

# ── Signals ───────────────────────────────────────────────────────────────────
signal panel_closed

# ── Constants ─────────────────────────────────────────────────────────────────
const MIN_SIZE := Vector2(900, 900)
const DEFAULT_SIZE := Vector2(1000, 1000)
const DEFAULT_POSITION := Vector2(0, 0)  # top right, offset from edge

# ── Node References ───────────────────────────────────────────────────────────
@onready var title_label= $PanelBackground/MarginContainer/VBoxContainer/Header/HFlowContainer/HFlowContainer2/TitleLabel
@onready var live_indicator: Label = $PanelBackground/MarginContainer/VBoxContainer/Header/HFlowContainer/HFlowContainer2/LiveIndicator
@onready var close_button: Button = $PanelBackground/MarginContainer/VBoxContainer/Header/HFlowContainer/HFlowContainer/CloseButton
@onready var subviewport: SubViewport = $PanelBackground/MarginContainer/VBoxContainer/NinePatchRect/SubViewportContainer/SubViewport
@onready var viewport_container: SubViewportContainer = $PanelBackground/MarginContainer/VBoxContainer/NinePatchRect/SubViewportContainer
@onready var header: Control = $PanelBackground/MarginContainer/VBoxContainer/Header
@onready var resize_handle: Control = $PanelBackground/ResizeHandle
@onready var panel_background: NinePatchRect = $PanelBackground


# ── Drag State ────────────────────────────────────────────────────────────────
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO


# ── Live Blink ────────────────────────────────────────────────────────────────
var _blink_timer: float = 0.0

# ── Current Building ──────────────────────────────────────────────────────────
var _current_building_id: String = ""
# ── Current Scene ─────────────────────────────────────────────────────────────
var _current_scene_instance: Node = null

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	CCTVManager.register_panel(self)
	# Default position — right side of screen
	var screen_size = get_viewport().get_visible_rect().size
	position = Vector2(screen_size.x - DEFAULT_SIZE.x - 20, 20)
	size = DEFAULT_SIZE
	
	close_button.pressed.connect(_on_close_pressed)
	
	# Header drag
	header.gui_input.connect(_on_header_input)
	
	# Resize handle
	#resize_handle.gui_input.connect(_on_resize_input)
	
	# Start hidden
	visible = false
	
	print("[CCTVPanel] Ready")


func _process(delta: float) -> void:
	# Dragging
	if _is_dragging:
		position = get_global_mouse_position() - _drag_offset
		_clamp_to_screen()
	
	
	# Live indicator blink
	_blink_timer += delta
	if _blink_timer >= 1.0:
		_blink_timer = 0.0
		live_indicator.visible = !live_indicator.visible

# ── Public API ────────────────────────────────────────────────────────────────

func open_feed(building_id: String, building_name: String, scene_path: String) -> void:
	print("open feed",building_id)
	#_current_building_id = building_id
	title_label.text = building_name
	visible = true
	
	# Clear previous scene
	#_clear_viewport()
	
	if _current_scene_instance==null or _current_building_id!=building_id:
		if _current_scene_instance:
			_current_scene_instance.queue_free()
			_current_scene_instance=null
						
		# Load interior scene into SubViewport
		if scene_path != "":
			var scene = load(scene_path)
			if scene:
				var instance = scene.instantiate()
				subviewport.add_child(instance)
				print("[CCTVPanel] Loaded feed: %s" % building_name)
			else:
				push_warning("[CCTVPanel] Could not load scene: %s" % scene_path)
		_current_building_id=building_id
		
		

func close_feed() -> void:
	#_clear_viewport()
	_current_building_id = ""
	visible = false
	panel_closed.emit()


func get_current_building() -> String:
	return _current_building_id

# ── Drag ──────────────────────────────────────────────────────────────────────

func _on_header_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
			if event.pressed:
				_drag_offset = get_global_mouse_position() - position
	
	if event is InputEventMouseMotion and _is_dragging:
		position = get_global_mouse_position() - _drag_offset
		_clamp_to_screen()

# ── Resize ────────────────────────────────────────────────────────────────────

# ── Close ─────────────────────────────────────────────────────────────────────

func _on_close_pressed() -> void:
	close_feed()

# ── Helpers ───────────────────────────────────────────────────────────────────

func _clear_viewport() -> void:
	for child in subviewport.get_children():
		child.queue_free()


func _clamp_to_screen() -> void:
	var screen = get_viewport().get_visible_rect().size
	position.x = clamp(position.x, 0, screen.x - size.x)
	position.y = clamp(position.y, 0, screen.y - size.y)
