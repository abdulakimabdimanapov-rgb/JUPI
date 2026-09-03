extends Node

## GameManager — Global game state (autoload)
## Tracks: XP, level, currency, kills, game state

signal xp_changed(xp: float, level: int)
signal level_up(new_level: int)
signal currency_changed(amount: int)
signal game_state_changed(old_state: int, new_state: int)

enum GameState { EXPLORING, COMBAT, PAUSED, DEAD }

var current_game_state: int = GameState.EXPLORING
var player_level: int = 1
var player_xp: float = 0.0
var xp_to_next_level: float = 50.0
var player_currency: int = 0
var total_kills: int = 0


func can_act() -> bool:
	return current_game_state in [GameState.EXPLORING, GameState.COMBAT]


func set_game_state(new_state: int) -> void:
	var old := current_game_state
	current_game_state = new_state
	game_state_changed.emit(old, new_state)


func add_xp(amount: float) -> void:
	player_xp += amount
	xp_changed.emit(player_xp, player_level)
	while player_xp >= xp_to_next_level:
		_level_up()


func _level_up() -> void:
	player_xp -= xp_to_next_level
	player_level += 1
	xp_to_next_level = 50.0 + (player_level - 1) * 30.0
	level_up.emit(player_level)
	xp_changed.emit(player_xp, player_level)


func add_currency(amount: int) -> void:
	player_currency += amount
	currency_changed.emit(player_currency)


func spend_currency(amount: int) -> bool:
	if player_currency >= amount:
		player_currency -= amount
		currency_changed.emit(player_currency)
		return true
	return false


## Reset per-run stats so a restart / new game starts clean.
func reset_run() -> void:
	current_game_state = GameState.EXPLORING
	player_level = 1
	player_xp = 0.0
	xp_to_next_level = 50.0
	player_currency = 0
	total_kills = 0


func get_level_damage_bonus() -> float:
	return (player_level - 1) * 3.0
