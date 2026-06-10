extends Node



# ── Dialogue ──────────────────────────────────────────────────────────────────
signal dialogue_requested(agent_data: CharacterData)
signal dialogue_closed
signal dialogue_message_sent(message: String, agent_data: CharacterData)
# PRESS E to Interact
signal interaction_alert(visible:bool,message:String)


# Scene Transition
signal scene_changed
