extends RefCounted
class_name AchievementSystem

signal achievement_unlocked(achievement: Dictionary)
signal achievement_progress(achievement: Dictionary, progress: float)

var achievements = {}
var unlocked = []
var progress = {}

func _init():
	_init_achievements()

func _init_achievements():
	achievements = {
		"first_kill": {
			"id": "first_kill",
			"name": "First Blood",
			"description": "Defeat your first enemy",
			"icon": "skull",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 50,
			"reward_currency": 100,
		},
		"kill_10": {
			"id": "kill_10",
			"name": "Veteran",
			"description": "Defeat 10 enemies",
			"icon": "skull",
			"hidden": false,
			"progress_max": 10,
			"reward_xp": 100,
			"reward_currency": 200,
		},
		"kill_50": {
			"id": "kill_50",
			"name": "Warrior",
			"description": "Defeat 50 enemies",
			"icon": "skull",
			"hidden": false,
			"progress_max": 50,
			"reward_xp": 200,
			"reward_currency": 500,
		},
		"kill_100": {
			"id": "kill_100",
			"name": "Legend",
			"description": "Defeat 100 enemies",
			"icon": "skull",
			"hidden": false,
			"progress_max": 100,
			"reward_xp": 500,
			"reward_currency": 1000,
		},
		"first_contract": {
			"id": "first_contract",
			"name": "Contractor",
			"description": "Complete your first contract",
			"icon": "scroll",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 75,
			"reward_currency": 150,
		},
		"contracts_5": {
			"id": "contracts_5",
			"name": "Professional",
			"description": "Complete 5 contracts",
			"icon": "scroll",
			"hidden": false,
			"progress_max": 5,
			"reward_xp": 200,
			"reward_currency": 400,
		},
		"contracts_10": {
			"id": "contracts_10",
			"name": "Master Contractor",
			"description": "Complete 10 contracts",
			"icon": "scroll",
			"hidden": false,
			"progress_max": 10,
			"reward_xp": 400,
			"reward_currency": 800,
		},
		"level_5": {
			"id": "level_5",
			"name": "Rising Star",
			"description": "Reach level 5",
			"icon": "star",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 100,
			"reward_currency": 200,
		},
		"level_10": {
			"id": "level_10",
			"name": "Seasoned Hunter",
			"description": "Reach level 10",
			"icon": "star",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 300,
			"reward_currency": 600,
		},
		"level_20": {
			"id": "level_20",
			"name": "Time Master",
			"description": "Reach level 20",
			"icon": "star",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 1000,
			"reward_currency": 2000,
		},
		"boss_slayer": {
			"id": "boss_slayer",
			"name": "Boss Slayer",
			"description": "Defeat your first boss",
			"icon": "crown",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 300,
			"reward_currency": 500,
		},
		"all_bosses": {
			"id": "all_bosses",
			"name": "Boss Hunter",
			"description": "Defeat all bosses",
			"icon": "crown",
			"hidden": false,
			"progress_max": 4,
			"reward_xp": 1000,
			"reward_currency": 2000,
		},
		"time_traveler": {
			"id": "time_traveler",
			"name": "Time Traveler",
			"description": "Visit all eras",
			"icon": "clock",
			"hidden": false,
			"progress_max": 4,
			"reward_xp": 500,
			"reward_currency": 1000,
		},
		"collector": {
			"id": "collector",
			"name": "Collector",
			"description": "Collect 100 loot items",
			"icon": "gem",
			"hidden": false,
			"progress_max": 100,
			"reward_xp": 300,
			"reward_currency": 600,
		},
		"rich": {
			"id": "rich",
			"name": "Wealthy",
			"description": "Accumulate 5000 credits",
			"icon": "coin",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 200,
			"reward_currency": 0,
		},
		"secret_finder": {
			"id": "secret_finder",
			"name": "Secret Finder",
			"description": "Discover 5 secrets",
			"icon": "eye",
			"hidden": true,
			"progress_max": 5,
			"reward_xp": 400,
			"reward_currency": 800,
		},
		"paradox_master": {
			"id": "paradox_master",
			"name": "Paradox Master",
			"description": "Trigger 3 paradox events",
			"icon": "infinity",
			"hidden": true,
			"progress_max": 3,
			"reward_xp": 500,
			"reward_currency": 1000,
		},
		"speedrunner": {
			"id": "speedrunner",
			"name": "Speedrunner",
			"description": "Complete a contract in under 60 seconds",
			"icon": "lightning",
			"hidden": true,
			"progress_max": 1,
			"reward_xp": 300,
			"reward_currency": 600,
		},
		"no_damage": {
			"id": "no_damage",
			"name": "Untouchable",
			"description": "Complete a boss fight without taking damage",
			"icon": "shield",
			"hidden": true,
			"progress_max": 1,
			"reward_xp": 500,
			"reward_currency": 1000,
		},
		"full_explorer": {
			"id": "full_explorer",
			"name": "Explorer",
			"description": "Discover all locations",
			"icon": "compass",
			"hidden": false,
			"progress_max": 20,
			"reward_xp": 400,
			"reward_currency": 800,
		},
		# === COMBO ACHIEVEMENTS ===
		"combo_3": {
			"id": "combo_3",
			"name": "Combo Starter",
			"description": "Reach a 3-hit combo",
			"icon": "lightning",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 75,
			"reward_currency": 150,
		},
		"combo_5": {
			"id": "combo_5",
			"name": "Combo Master",
			"description": "Reach a 5-hit combo",
			"icon": "lightning",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 150,
			"reward_currency": 300,
		},
		"combo_10": {
			"id": "combo_10",
			"name": "Combo Legend",
			"description": "Reach a 10-hit combo",
			"icon": "lightning",
			"hidden": false,
			"progress_max": 1,
			"reward_xp": 300,
			"reward_currency": 600,
		},
		"combo_kills_3": {
			"id": "combo_kills_3",
			"name": "Streak Slayer",
			"description": "Kill 3 enemies in a single combo chain",
			"icon": "skull",
			"hidden": false,
			"progress_max": 3,
			"reward_xp": 200,
			"reward_currency": 400,
		},
		"combo_kills_5": {
			"id": "combo_kills_5",
			"name": "Streak Destroyer",
			"description": "Kill 5 enemies in a single combo chain",
			"icon": "skull",
			"hidden": false,
			"progress_max": 5,
			"reward_xp": 400,
			"reward_currency": 800,
		},
		"combo_finisher_5": {
			"id": "combo_finisher_5",
			"name": "Finisher Fanatic",
			"description": "Land 5 combo finishers (3rd hit special attacks)",
			"icon": "crown",
			"hidden": false,
			"progress_max": 5,
			"reward_xp": 250,
			"reward_currency": 500,
		},
		"combo_finisher_weapon_3": {
			"id": "combo_finisher_weapon_3",
			"name": "Weapon Connoisseur",
			"description": "Land combo finishers with 3 different combo weapons",
			"icon": "gem",
			"hidden": false,
			"progress_max": 3,
			"reward_xp": 350,
			"reward_currency": 700,
		},
		"dash_kill_5": {
			"id": "dash_kill_5",
			"name": "Dash Slayer",
			"description": "Kill 5 enemies with dash attacks",
			"icon": "lightning",
			"hidden": false,
			"progress_max": 5,
			"reward_xp": 200,
			"reward_currency": 400,
		},
		"status_kill_poison": {
			"id": "status_kill_poison",
			"name": "Toxicologist",
			"description": "Kill 3 enemies with poison damage",
			"icon": "skull",
			"hidden": false,
			"progress_max": 3,
			"reward_xp": 150,
			"reward_currency": 300,
		},
		"status_kill_burn": {
			"id": "status_kill_burn",
			"name": "Pyromaniac",
			"description": "Kill 3 enemies with burn damage",
			"icon": "skull",
			"hidden": false,
			"progress_max": 3,
			"reward_xp": 150,
			"reward_currency": 300,
		},
		"perfect_combo": {
			"id": "perfect_combo",
			"name": "Flawless Fury",
			"description": "Reach a 10-hit combo without taking damage",
			"icon": "shield",
			"hidden": true,
			"progress_max": 1,
			"reward_xp": 500,
			"reward_currency": 1000,
		},
	}

func update_progress(achievement_id, amount = 1):
	if not achievements.has(achievement_id):
		return
	if unlocked.has(achievement_id):
		return

	if not progress.has(achievement_id):
		progress[achievement_id] = 0

	progress[achievement_id] += amount

	var achievement = achievements[achievement_id]
	var max_progress = achievement.get("progress_max", 1)
	achievement_progress.emit(achievement, float(progress[achievement_id]) / float(max_progress))

	if progress[achievement_id] >= max_progress:
		_unlock(achievement_id)

func _unlock(achievement_id):
	if unlocked.has(achievement_id):
		return

	unlocked.append(achievement_id)
	var achievement = achievements[achievement_id]

	if GameManager:
		if achievement.has("reward_xp"):
			GameManager.add_xp(achievement["reward_xp"])
		if achievement.has("reward_currency"):
			GameManager.add_currency(achievement["reward_currency"])

	achievement_unlocked.emit(achievement)

func is_unlocked(achievement_id):
	return unlocked.has(achievement_id)

func get_progress(achievement_id):
	return progress.get(achievement_id, 0)

func get_all_achievements():
	return achievements.duplicate()

func get_unlocked_count():
	return unlocked.size()

func get_total_count():
	return achievements.size()

func get_completion_percent():
	if achievements.is_empty():
		return 0.0
	return float(unlocked.size()) / float(achievements.size()) * 100.0

func get_save_data():
	return {
		"unlocked": unlocked.duplicate(),
		"progress": progress.duplicate(),
	}

func load_save_data(data):
	unlocked = data.get("unlocked", [])
	progress = data.get("progress", {})
                