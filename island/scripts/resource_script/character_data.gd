extends Resource
class_name CharacterData


# ── Identity ────────────────────────────────────────
@export var character_id: String = ""
@export var character_name: String = ""
@export_multiline var character_description: String = ""

# ── Profession ──────────────────────────────────────

@export var profession: String = ""
@export_multiline var job_description: String = ""
@export_multiline var daily_routine: String = ""

# ── Personality ────────────────────────────────────
@export var personality_traits: Array[String] = []
# Examples: ["curious", "pragmatic", "generous", "secretive", "ambitious"]

@export var likes: Array[String] = []
@export var dislikes: Array[String] = []

# ── Appearance ──────────────────────────────────────
# SpriteFrames for each body part
@export var sprite_body: SpriteFrames
@export var sprite_clothing: SpriteFrames
@export var sprite_hair: SpriteFrames
@export var sprite_accessory: SpriteFrames

# ── Stats ───────────────────────────────────────────
@export var starting_location_id: String = ""
@export var health: int = 100
@export var energy: int = 100
@export var schedule:AgentSchedule

# ── Relationships ───────────────────────────────────
@export var relationship_modifiers: Dictionary = {}  # character_id -> opinion modifier

# ── Helper Functions ────────────────────────────────

func get_personality_string() -> String:
	return ", ".join(personality_traits)

func to_dict() -> Dictionary:
	return {
		"id": character_id,
		"name": character_name,
		"description": character_description,
		"profession": profession,
		"job_description": job_description,
		"personality": personality_traits,
		"likes": likes,
		"dislikes": dislikes,
		"starting_location": starting_location_id,
	}
