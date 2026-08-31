extends RefCounted
class_name ClockAI


signal clock_said(text: String, mood: String)

var mood: String = "neutral"
var trust_level: int = 0
var hidden_knowledge: Array[String] = []
var told_secrets: Array[String] = []

var dialogue_styles := {
	"neutral": [
		"Clock ticking. Task ahead.",
		"Time is… relevant.",
		"I note the date.",
		"Proceed.",
	],
	"amused": [
		"Interesting choice.",
		"You think that will work?",
		"Time will tell. Literally.",
		"I've seen worse plans.",
	],
	"concerned": [
		"Be careful here.",
		"I sense… disturbance.",
		"This era is volatile.",
		"Watch yourself.",
	],
	"secretive": [
		"I know more than I say.",
		"That question… is premature.",
		"Some doors are better left closed.",
		"You're not ready for that answer.",
	],
	"angry": [
		"You're wasting time.",
		"This was a mistake.",
		"I won't forget this.",
		"Clock is… displeased.",
	],
	"nostalgic": [
		"I remember this place.",
		"Once, there was a different world here.",
		"The clocks tick differently now.",
		"Some echoes never fade.",
	],
}

var target_knowledge: Dictionary = {}
var era_knowledge: Dictionary = {
	"ancient": {"name": "The Ancient Age", "danger": "low", "tech": "primal"},
	"medieval": {"name": "The Iron Century", "danger": "medium", "tech": "medieval"},
	"industrial": {"name": "The Smoke Era", "danger": "medium", "tech": "early_firearms"},
	"modern": {"name": "The Present Day", "danger": "high", "tech": "modern"},
	"near_future": {"name": "The Bleeding Edge", "danger": "very_high", "tech": "cybernetic"},
	"far_future": {"name": "The Last Dawn", "danger": "extreme", "tech": "quantum"},
}

func _init() -> void:
	pass

func respond_to(question: String, context: Dictionary = {}) -> String:
	var era: String = context.get("era", "modern")
	var has_contract: bool = not context.get("contract", {}).is_empty()

	if question.contains("who") or question.contains("target"):
		return _respond_target(context)
	elif question.contains("where") or question.contains("location"):
		return _respond_location(context)
	elif question.contains("when") or question.contains("era") or question.contains("time"):
		return _respond_time(context)
	elif question.contains("danger") or question.contains("safe"):
		return _respond_danger(context)
	elif question.contains("you") or question.contains("clock") or question.contains("yourself"):
		return _respond_about_self(context)
	elif question.contains("plan") or question.contains("how"):
		return _respond_plan(context)
	else:
		return _neutral_response()

func _respond_target(ctx: Dictionary) -> String:
	var contract: Dictionary = ctx.get("contract", {})
	if contract.is_empty():
		return _mood_say("neutral", "No active contract. Check your clock menu.")
	var target: String = contract.get("target_name", "Unknown")
	var era: String = contract.get("era", "unknown")
	var info_level: int = trust_level / 20
	if info_level >= 3:
		return _mood_say("neutral", "Target: %s. Era: %s. Threat level: %s." % [target, era, contract.get("threat", "?")])
	elif info_level >= 1:
		return _mood_say("concerned", "Target exists in %s. I know more… but not yet." % era)
	else:
		return _mood_say("secretive", "The name will come. Be patient.")

func _respond_location(ctx: Dictionary) -> String:
	var contract: Dictionary = ctx.get("contract", {})
	if contract.is_empty():
		return _mood_say("neutral", "No destination set.")
	var country: String = contract.get("country", "???")
	var city: String = contract.get("city", "???")
	return _mood_say("neutral", "%s. %s. I can guide you there." % [country, city])

func _respond_time(ctx: Dictionary) -> String:
	var contract: Dictionary = ctx.get("contract", {})
	var era: String = contract.get("era", ctx.get("era", "modern"))
	if era_knowledge.has(era):
		var info: Dictionary = era_knowledge[era]
		return _mood_say("concerned", "%s. Tech level: %s. Danger: %s." % [info.name, info.tech, info.danger])
	return _mood_say("neutral", "Era: %s. I'll handle the navigation." % era)

func _respond_danger(ctx: Dictionary) -> String:
	var threat: String = ctx.get("contract", {}).get("threat", "unknown")
	match threat:
		"low": return _mood_say("amused", "Minimal risk. Almost boring.")
		"medium": return _mood_say("neutral", "Manageable. Stay alert.")
		"high": return _mood_say("concerned", "Significant danger. Prepare properly.")
		"extreme": return _mood_say("angry", "You're not ready for this. But you'll go anyway.")
		_: return _mood_say("neutral", "Threat assessment… inconclusive.")

func _respond_about_self(ctx: Dictionary) -> String:
	if trust_level < 10:
		return _mood_say("secretive", "I am your timepiece. That is sufficient.")
	elif trust_level < 30:
		return _mood_say("neutral", "I am old. Older than most civilizations you've visited.")
	elif trust_level < 60:
		return _mood_say("nostalgic", "I have… memories. Not all of them are comfortable.")
	else:
		return _mood_say("nostalgic", "I was made. By someone. In a time you haven't reached yet.")

func _respond_plan(ctx: Dictionary) -> String:
	var contract: Dictionary = ctx.get("contract", {})
	if contract.is_empty():
		return _mood_say("neutral", "No contract active. Open the clock menu to receive one.")
	return _mood_say("amused", "Observe first. Act second. The target has a schedule. Find it.")

func _neutral_response() -> String:
	return _mood_say("neutral", _pick_random(dialogue_styles["neutral"]))

func _mood_say(m: String, text: String) -> String:
	mood = m
	clock_said.emit(text, mood)
	return text

func _pick_random(arr: Array) -> String:
	if arr.is_empty():
		return "..."
	return arr[randi() % arr.size()]

func analyze_character(char_name: String) -> Dictionary:
	var result := {"name": char_name, "threat": "unknown", "era": "unknown", "notes": []}
	if target_knowledge.has(char_name):
		result = target_knowledge[char_name]
	if trust_level > 20:
		result.notes.append("Clock has additional data… sharing gradually.")
	return result
