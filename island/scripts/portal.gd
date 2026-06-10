class_name Portal
extends Area2D

# ── Exports ───────────────────────────────────────────────────────────────────

# Unique ID for this portal — other portals reference this
@export var portal_id: String = ""

# Which scene this portal leads to
@export var target_scene: String = ""

# Which portal in the target scene to spawn the player at
@export var target_location_id: String = ""

@export var exit_portal:bool;

# ── Internal ──────────────────────────────────────────────────────────────────

var _entered_player: Character = null
var _in_zone: bool = false

@onready var return_spawn_point: Marker2D = $ReturnSpawnPoint

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	print("[Portal:%s] Ready" % portal_id)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _in_zone:
		_transition()

# ── Body Detection ────────────────────────────────────────────────────────────

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("agent"):
		return
	
	var agent: Character = body as Character
	
	if agent.type == Character.TYPE.AGENT:
		# NPC walks into portal — update registry and despawn
		'''
		AgentStateRegistry.update_location(
			agent.character_data.character_id,
			target_location_id
		)
		'''
		agent.get_parent().remove_child(agent)
		agent.queue_free()
		return
	
	if agent.type == Character.TYPE.PLAYER:
		_entered_player = agent
		_in_zone = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("agent"):
		return
	
	var agent: Character = body as Character
	
	if agent.type == Character.TYPE.PLAYER:
		_entered_player = null
		_in_zone = false

# ── Transition ────────────────────────────────────────────────────────────────

func _transition() -> void:
	if not _entered_player:
		return
	if target_scene.is_empty():
		push_warning("[Portal:%s] No target scene set" % portal_id)
		return
	
	var agent_id: String = _entered_player.character_data.character_id
	
	# Tell registry where player is going
	AgentStateRegistry.update_location(agent_id, target_location_id)
	

	AgentStateRegistry.set_spawn_portal_id(agent_id,portal_id)
	# Tell registry which portal to spawn at in target scene
	#AgentStateRegistry.set_spawn_portal(agent_id, target_location_id)
	
	print("[Portal:%s] Transitioning to %s, spawn at %s" % [
		portal_id, target_scene, target_location_id
	])
	
	# Switch scene
	var scene = load(target_scene)
	SceneManager.switch_scene(scene)

# ── Public ────────────────────────────────────────────────────────────────────

func get_spawn_position() -> Vector2:
	return return_spawn_point.global_position

func get_portal_id() -> String:
	return portal_id
