extends Node
## Input remapping manager — saves custom keybinds to user://keybinds.json

signal binding_changed(action: String, event: InputEvent)

# All rebindable actions with display names
var ACTIONS := {
	"move_up": "Move Up",
	"move_down": "Move Down",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"sprint": "Sprint",
	"attack": "Attack",
	"alt_attack": "Alt Attack",
	"dodge": "Dodge",
	"interact": "Interact",
	"blood_clock": "Blood Clock",
	"pause": "Pause",
	"slot_1": "Weapon Slot 1",
	"slot_2": "Weapon Slot 2",
	"slot_3": "Weapon Slot 3",
	"slot_4": "Weapon Slot 4",
}

var _waiting_for_input: String = ""  # action currently being remapped

# Arrow keys always stay available for movement on top of any user binding
const ARROW_MOVEMENT_KEYS := {
	"move_up": KEY_UP,
	"move_down": KEY_DOWN,
	"move_left": KEY_LEFT,
	"move_right": KEY_RIGHT,
}

const SAVE_PATH := "user://keybinds.json"


func _ready() -> void:
	load_bindings()


func load_bindings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK:
		return
	var data = json.data
	if not data is Dictionary:
		return
	for action in data:
		if not ACTIONS.has(action):
			continue
		var ev_data: Dictionary = data[action]
		var ev := InputEventKey.new()
		ev.physical_keycode = ev_data.get("physical_keycode", 0)
		ev.keycode = ev_data.get("keycode", 0)
		ev.alt_pressed = ev_data.get("alt_pressed", false)
		ev.ctrl_pressed = ev_data.get("ctrl_pressed", false)
		ev.shift_pressed = ev_data.get("shift_pressed", false)
		# Clear old bindings
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, ev)
	_ensure_movement_arrows()


func _ensure_movement_arrows() -> void:
	# Movement always supports arrows (WASD + arrows), even when keybinds file
	# or defaults only saved the WASD binding.
	for action in ARROW_MOVEMENT_KEYS:
		var has_arrow := false
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				var ie: InputEventKey = ev
				if ie.physical_keycode == ARROW_MOVEMENT_KEYS[action] or ie.keycode == ARROW_MOVEMENT_KEYS[action]:
					has_arrow = true
					break
		if not has_arrow:
			var arrow := InputEventKey.new()
			arrow.physical_keycode = ARROW_MOVEMENT_KEYS[action]
			InputMap.action_add_event(action, arrow)


func save_bindings() -> void:
	var data := {}
	for action in ACTIONS:
		var events := InputMap.action_get_events(action)
		if events.size() > 0:
			var ev: InputEvent = events[0]
			if ev is InputEventKey:
				data[action] = {
					"physical_keycode": ev.physical_keycode,
					"keycode": ev.keycode,
					"alt_pressed": ev.alt_pressed,
					"ctrl_pressed": ev.ctrl_pressed,
					"shift_pressed": ev.shift_pressed,
				}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


func reset_to_defaults() -> void:
	var defaults := {
		"move_up": KEY_W, "move_down": KEY_S,
		"move_left": KEY_A, "move_right": KEY_D,
		"sprint": KEY_SHIFT, "dodge": KEY_SPACE,
		"interact": KEY_E, "blood_clock": KEY_Q,
		"pause": KEY_ESCAPE,
		"slot_1": KEY_1, "slot_2": KEY_2,
		"slot_3": KEY_3, "slot_4": KEY_4,
	}
	for action in ACTIONS:
		InputMap.action_erase_events(action)
		if defaults.has(action):
			var ev := InputEventKey.new()
			ev.physical_keycode = defaults[action]
			InputMap.action_add_event(action, ev)
	_ensure_movement_arrows()
	# Mouse buttons for attack
	var lmb := InputEventMouseButton.new()
	lmb.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("attack", lmb)
	var rmb := InputEventMouseButton.new()
	rmb.button_index = MOUSE_BUTTON_RIGHT
	InputMap.action_add_event("alt_attack", rmb)
	save_bindings()


func start_rebind(action: String) -> void:
	_waiting_for_input = action


func is_rebinding() -> bool:
	return _waiting_for_input != ""


func get_rebinding_action() -> String:
	return _waiting_for_input


func get_display_name(action: String) -> String:
	return ACTIONS.get(action, action)


func get_current_binding(action: String) -> String:
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "[NOT SET]"
	var ev: InputEvent = events[0]
	if ev is InputEventMouseButton:
		match ev.button_index:
			MOUSE_BUTTON_LEFT: return "LMB"
			MOUSE_BUTTON_RIGHT: return "RMB"
			MOUSE_BUTTON_MIDDLE: return "MMB"
			MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
			_: return "Mouse %d" % ev.button_index
	elif ev is InputEventKey:
		return OS.get_keycode_string(ev.keycode if ev.keycode != 0 else ev.physical_keycode)
	return "???"


func _unhandled_input(event: InputEvent) -> void:
	if _waiting_for_input == "":
		return
	if not (event is InputEventKey and event.pressed):
		if not (event is InputEventMouseButton and event.pressed):
			return

	# Cancel with Escape
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		_waiting_for_input = ""
		binding_changed.emit("", null)
		get_viewport().set_input_as_handled()
		return

	# Set new binding
	InputMap.action_erase_events(_waiting_for_input)
	InputMap.action_add_event(_waiting_for_input, event)
	var action := _waiting_for_input
	_waiting_for_input = ""
	save_bindings()
	binding_changed.emit(action, event)
	get_viewport().set_input_as_handled()
