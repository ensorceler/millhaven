extends Node

# ── Signals ───────────────────────────────────────────────────────────────────

# Fires every in-game minute
signal minute_changed(hour: int, minute: int)

# Fires every in-game hour
signal hour_changed(hour: int)

# Fires when time block transitions e.g. Morning → Noon
signal time_block_changed(old_block: TimeBlock, new_block: TimeBlock)

# Fires when a new day begins (midnight rollover)
signal day_changed(day: int)

# Reserved for future use — pause/resume system
signal clock_paused
signal clock_resumed

# ── Time Blocks ───────────────────────────────────────────────────────────────

enum TimeBlock {
	MORNING,    # 06:00 → 11:00
	NOON,       # 11:00 → 13:00
	AFTERNOON,  # 13:00 → 18:00
	EVENING,    # 18:00 → 22:00
	NIGHT       # 22:00 → 06:00
}

# Human readable names for LLM prompts and debug
const TIME_BLOCK_NAMES: Dictionary = {
	TimeBlock.MORNING:   "morning",
	TimeBlock.NOON:      "noon",
	TimeBlock.AFTERNOON: "afternoon",
	TimeBlock.EVENING:   "evening",
	TimeBlock.NIGHT:     "night",
}

# Hour boundaries for each block
const TIME_BLOCK_START_HOURS: Dictionary = {
	TimeBlock.MORNING:   6,
	TimeBlock.NOON:      11,
	TimeBlock.AFTERNOON: 13,
	TimeBlock.EVENING:   18,
	TimeBlock.NIGHT:     22,
}

# ── Configuration ─────────────────────────────────────────────────────────────

# How many in-game minutes pass per real second
# Default: 1 real second = 1 in-game minute
# Change at runtime or in Inspector to speed up/slow down simulation
@export var time_scale: float = 1.0

# Starting time — dawn
@export var start_hour: int = 6
@export var start_minute: int = 0

# ── Internal State ────────────────────────────────────────────────────────────

var current_hour: int = 6
var current_minute: int = 0
var current_day: int = 1
var current_block: TimeBlock = TimeBlock.MORNING

# Accumulator — tracks partial minutes between frames
var _time_accumulator: float = 0.0

# Pause state — dormant for now, ready to wire up later
var _is_paused: bool = false

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	current_hour   = start_hour
	current_minute = start_minute
	current_block  = _calculate_block(current_hour)
	print("[SimulationClock] Started at %s on Day %d" % [get_time_string(), current_day])


func _process(delta: float) -> void:
	if _is_paused:
		return

	_time_accumulator += delta * time_scale

	# Each full unit of accumulator = one in-game minute
	while _time_accumulator >= 1.0:
		_time_accumulator -= 1.0
		_advance_minute()

# ── Time Advancement ──────────────────────────────────────────────────────────

func _advance_minute() -> void:
	current_minute += 1

	if current_minute >= 60:
		current_minute = 0
		_advance_hour()
	
	minute_changed.emit(current_hour, current_minute)


func _advance_hour() -> void:
	current_hour += 1

	if current_hour >= 24:
		current_hour = 0
		current_day += 1
		day_changed.emit(current_day)

	# Check if time block changed
	var new_block: TimeBlock = _calculate_block(current_hour)
	if new_block != current_block:
		var old_block: TimeBlock = current_block
		current_block = new_block
		time_block_changed.emit(old_block, new_block)
		print("[SimulationClock] Time block changed: %s → %s" % [
			get_block_name(old_block),
			get_block_name(new_block)
		])

	hour_changed.emit(current_hour)

# ── Block Calculation ─────────────────────────────────────────────────────────

func _calculate_block(hour: int) -> TimeBlock:
	if hour >= 6  and hour < 11: return TimeBlock.MORNING
	if hour >= 11 and hour < 13: return TimeBlock.NOON
	if hour >= 13 and hour < 18: return TimeBlock.AFTERNOON
	if hour >= 18 and hour < 22: return TimeBlock.EVENING
	return TimeBlock.NIGHT

# ── Pause / Resume (dormant — wire up later) ──────────────────────────────────

func pause() -> void:
	if _is_paused:
		return
	_is_paused = true
	clock_paused.emit()
	print("[SimulationClock] Paused at %s" % get_time_string())


func resume() -> void:
	if not _is_paused:
		return
	_is_paused = false
	clock_resumed.emit()
	print("[SimulationClock] Resumed at %s" % get_time_string())


func toggle_pause() -> void:
	if _is_paused:
		resume()
	else:
		pause()

# ── Public Query Functions ────────────────────────────────────────────────────
# These are what agents and other systems call to ask about current time

func get_time_string() -> String:
	# Returns human readable time e.g. "08:30"
	return "%02d:%02d" % [current_hour, current_minute]


func get_block_name(block: TimeBlock = current_block) -> String:
	# Returns string name e.g. "morning" — used in LLM prompts
	return TIME_BLOCK_NAMES.get(block, "unknown")


func get_current_block() -> TimeBlock:
	return current_block


func is_block(block: TimeBlock) -> bool:
	return current_block == block


func is_daytime() -> bool:
	# Convenience — anything that isn't night
	return current_block != TimeBlock.NIGHT


func is_nighttime() -> bool:
	return current_block == TimeBlock.NIGHT


func get_day() -> int:
	return current_day


func get_full_context() -> Dictionary:
	# Returns everything in one dict — used by Rust/LLM for context
	return {
		"day":        current_day,
		"hour":       current_hour,
		"minute":     current_minute,
		"time_string": get_time_string(),
		"time_block": get_block_name(),
		"is_paused":  _is_paused,
	}
