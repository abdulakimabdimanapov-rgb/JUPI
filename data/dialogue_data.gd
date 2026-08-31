class_name DialogueData
extends RefCounted





static var DIALOGUES: Dictionary = {
	"informant_intro": {
		"speaker": "Informant",
		"nodes": {
			"start": {
				"text": "You're the one they call the Blood Hunter? I've been expecting you.",
				"next": "info_1"
			},
			"info_1": {
				"text": "Something strange is happening with the timeline. The Clock Tower... it's malfunctioning.",
				"next": "info_2"
			},
			"info_2": {
				"text": "I know a man who can help. But he's hiding in the old Workshop. Be careful — guards patrol the area.",
				"choices": [
					{"text": "I'll find him.", "next": "info_3", "flag": "accepted_workshop_quest"},
					{"text": "Tell me more first.", "next": "info_4"},
					{"text": "I work alone.", "next": "info_5"}
				]
			},
			"info_3": {
				"text": "Good. Look for the Workshop in the northeast block. Tell him I sent you.",
				"effects": {"xp": 10.0, "set_flag": "informant_talked"},
				"next": ""
			},
			"info_4": {
				"text": "There are... echoes. The past and future are bleeding into each other. I've seen things that shouldn't exist in this era.",
				"next": "info_3"
			},
			"info_5": {
				"text": "Suit yourself. But trust me — you can't fight this alone. The Blood Clock has seen things...",
				"effects": {"set_flag": "informant_talked"}
			}
		}
	},

	"workshop_engineer": {
		"speaker": "Engineer",
		"nodes": {
			"start": {
				"text": "Who sent you? ...Wait, I don't care. You look like someone who gets things done.",
				"next": "eng_1",
				"require_flag": "accepted_workshop_quest"
			},
			"eng_1": {
				"text": "The Time Machine in the Clock Tower is our only hope. But the power cells are depleted.",
				"next": "eng_2"
			},
			"eng_2": {
				"text": "I need you to collect 3 Chrono Shards from the enemies near the Clock Tower. They've absorbed temporal energy.",
				"choices": [
					{"text": "On my way.", "next": "eng_accept", "flag": "eng_quest_accepted"},
					{"text": "What's in it for me?", "next": "eng_reward"},
					{"text": "What are Chrono Shards?", "next": "eng_explain"}
				]
			},
			"eng_accept": {
				"text": "Excellent. Come back when you have them. And watch out for the heavy patrols.",
				"effects": {"xp": 15.0, "set_flag": "workshop_quest_started"}
			},
			"eng_reward": {
				"text": "I'll upgrade your weapon. Trust me — my tech is decades ahead of anything you've seen.",
				"next": "eng_accept"
			},
			"eng_explain": {
				"text": "Fragments of crystallized time. When a creature is touched by temporal energy, the excess crystallizes in their body. The Clock Tower can absorb them.",
				"next": "eng_accept"
			}
		}
	},

	"civilian_01": {
		"speaker": "Pedestrian",
		"nodes": {
			"start": {
				"text": "Nice night for a walk, isn't it? ...If you ignore the armed patrols, that is.",
				"next": ""
			}
		}
	},

	"civilian_02": {
		"speaker": "Merchant",
		"nodes": {
			"start": {
				"text": "I hear the Trader has some new stock. But you need credits... lots of credits.",
				"next": ""
			}
		}
	},

	"civilian_03": {
		"speaker": "Drifter",
		"nodes": {
			"start": {
				"text": "They say there's a Time Machine hidden somewhere in the city. If only someone could activate it...",
				"next": "drift_1"
			},
			"drift_1": {
				"text": "I've heard rumors of a Warlord in the past. An Android in the future. And something... worse in the Collapsed Era.",
				"next": ""
			}
		}
	},

	"civilian_04": {
		"speaker": "Worker",
		"nodes": {
			"start": {
				"text": "Another night shift. The Clock Tower chimes are getting stranger lately.",
				"next": ""
			}
		}
	},

	"civilian_05": {
		"speaker": "Resident",
		"nodes": {
			"start": {
				"text": "Did you hear that? The walls... they sometimes whisper. I think it's the time distortions.",
				"next": ""
			}
		}
	},

	"past_merchant": {
		"speaker": "Merchant",
		"nodes": {
			"start": {
				"text": "Welcome, traveler! I don't see your kind around here often. You carry strange weapons.",
				"next": "pm_1"
			},
			"pm_1": {
				"text": "The village is in danger. The Warlord's soldiers patrol the borders. We need help.",
				"choices": [
					{"text": "Tell me about the Warlord.", "next": "pm_warlord"},
					{"text": "I'll help defend the village.", "next": "pm_defend", "flag": "past_village_defend_started"},
					{"text": "I have my own mission.", "next": ""}
				]
			},
			"pm_warlord": {
				"text": "He came from the east. Took the old fortress. His soldiers are well-equipped — for this era at least. He's obsessed with 'the future'.",
				"next": "pm_defend"
			},
			"pm_defend": {
				"text": "Thank you! The village elder can tell you more. He's in the main hall.",
				"effects": {"xp": 20.0, "set_flag": "met_past_merchant"}
			}
		}
	},

	"past_elder": {
		"speaker": "Village Elder",
		"nodes": {
			"start": {
				"text": "You... you don't belong to this time, do you? I can see it in your eyes.",
				"next": "pe_1"
			},
			"pe_1": {
				"text": "I've seen visions of the future. Of machines and steel. And of a great darkness.",
				"choices": [
					{"text": "I'm from the future. I'm here to help.", "next": "pe_2"},
					{"text": "What darkness do you speak of?", "next": "pe_3"}
				]
			},
			"pe_2": {
				"text": "Then perhaps there is hope. The Warlord — he found a portal. He thinks he can use it to conquer other eras.",
				"next": "pe_3"
			},
			"pe_3": {
				"text": "If you defeat the Warlord, you may change the course of history. But be warned — every change has consequences.",
				"effects": {"xp": 30.0, "set_flag": "elder_quest_given"}
			}
		}
	},

	"past_guard": {
		"speaker": "Guard Captain",
		"nodes": {
			"start": {
				"text": "Halt! Who goes there? ...A stranger? We don't get many strangers.",
				"next": "pg_1"
			},
			"pg_1": {
				"text": "The Warlord's scouts have been spotted near the south road. Stay alert.",
				"next": ""
			}
		}
	},

	"future_engineer": {
		"speaker": "Engineer",
		"nodes": {
			"start": {
				"text": "Fascinating... your temporal signature is anomalous. You're not from this timeline.",
				"next": "fe_1"
			},
			"fe_1": {
				"text": "The Cyber Guardian controls the power grid. Without it, we can't maintain the temporal stabilizers.",
				"choices": [
					{"text": "How do I disable the Cyber Guardian?", "next": "fe_2"},
					{"text": "What happens if the stabilizers fail?", "next": "fe_3"}
				]
			},
			"fe_2": {
				"text": "It's located in the Central Nexus. Approach from the east — the west corridor is heavily guarded by drones.",
				"effects": {"xp": 25.0, "set_flag": "future_guardian_quest"}
			},
			"fe_3": {
				"text": "Then this era collapses. Everything becomes... the Collapsed Future. A wasteland of broken time.",
				"next": "fe_2"
			}
		}
	},

	"future_scientist": {
		"speaker": "Scientist",
		"nodes": {
			"start": {
				"text": "My readings are off the charts. Another time traveler? In MY laboratory?",
				"next": "fs_1"
			},
			"fs_1": {
				"text": "I've been studying the temporal anomalies. Each paradox creates a ripple — some beneficial, some catastrophic.",
				"next": ""
			}
		}
	},

	"collapsed_survivor": {
		"speaker": "Survivor",
		"nodes": {
			"start": {
				"text": "You're alive? Truly alive? I haven't seen anyone from outside in... I don't know how long.",
				"next": "cs_1"
			},
			"cs_1": {
				"text": "The Time Devourer consumed everything. The past, the present, the future — all twisted together.",
				"choices": [
					{"text": "How do we stop it?", "next": "cs_2"},
					{"text": "Is there any hope?", "next": "cs_3"}
				]
			},
			"cs_2": {
				"text": "The Chrono Shard. It's the only thing that can seal the rift. But the Devourer guards it fiercely.",
				"effects": {"xp": 40.0, "set_flag": "collapsed_quest_started"}
			},
			"cs_3": {
				"text": "As long as someone fights... there's always hope. Take this — it's all I have left.",
				"next": "cs_2"
			}
		}
	},

	"collapsed_scavenger": {
		"speaker": "Scavenger",
		"nodes": {
			"start": {
				"text": "Everything here is broken. Time itself is broken. But there's still value in the rubble.",
				"next": ""
			}
		}
	},

	"boss_corporate": {
		"speaker": "Corporate Enforcer",
		"nodes": {
			"start": {
				"text": "You think you can disrupt our operations? The corporation will not tolerate interference.",
				"next": "bce_1"
			},
			"bce_1": {
				"text": "I've been enhanced. Bio-mechanical upgrades. You're just flesh and bone.",
				"choices": [
					{"text": "Then we'll see whose is stronger.", "next": ""},
					{"text": "What corporation?", "next": "bce_2"}
				]
			},
			"bce_2": {
				"text": "Temporal Dynamics Inc. We control the flow of time itself. Or... we did. Before you started breaking things.",
				"next": ""
			}
		}
	},

	"boss_warlord": {
		"speaker": "The Warlord",
		"nodes": {
			"start": {
				"text": "So. The future sends its champion to the past. How... predictable.",
				"next": "bwl_1"
			},
			"bwl_1": {
				"text": "I've seen your world. Cold. Sterile. Controlled by machines. I will build something better.",
				"next": ""
			}
		}
	},

	"boss_cyber": {
		"speaker": "Cyber Guardian",
		"nodes": {
			"start": {
				"text": "ANOMALY DETECTED. TEMPORAL SIGNATURE: UNAUTHORIZED. INITIATING CONTAINMENT PROTOCOL.",
				"next": ""
			}
		}
	},

	"boss_devourer": {
		"speaker": "Time Devourer",
		"nodes": {
			"start": {
				"text": "I am the end of all timelines. Every era you have visited... I consumed them.",
				"next": "btd_1"
			},
			"btd_1": {
				"text": "Your little clock, your little weapons — they mean nothing against the entropy of existence.",
				"choices": [
					{"text": "Then I'll create a new beginning.", "next": ""},
					{"text": "What do you want?", "next": "btd_2"}
				]
			},
			"btd_2": {
				"text": "Peace. True peace. When all of time is one... there is no conflict. No pain. No change.",
				"next": ""
			}
		}
	},

	"time_machine_intro": {
		"speaker": "Time Machine",
		"nodes": {
			"start": {
				"text": "TEMPORAL INTERFACE ACTIVE. Select destination era.",
				"next": ""
			}
		}
	},
}


static var NPC_DIALOGUES: Dictionary = {
	"Informant": "informant_intro",
	"Engineer": "workshop_engineer",
	"Pedestrian": "civilian_01",
	"Merchant": "civilian_02",
	"Drifter": "civilian_03",
	"Worker": "civilian_04",
	"Resident": "civilian_05",
	"Past Merchant": "past_merchant",
	"Village Elder": "past_elder",
	"Guard Captain": "past_guard",
	"Future Engineer": "future_engineer",
	"Future Scientist": "future_scientist",
	"Survivor": "collapsed_survivor",
	"Scavenger": "collapsed_scavenger",
}


static func get_dialogue(dialogue_id: String) -> Dictionary:
	return DIALOGUES.get(dialogue_id, {})

static func get_npc_dialogue(npc_name: String) -> Dictionary:
	var d_id: String = NPC_DIALOGUES.get(npc_name, "")
	if d_id == "":
		return {}
	return DIALOGUES.get(d_id, {})

static func get_dialogue_node(dialogue_id: String, node_id: String) -> Dictionary:
	var dialogue := get_dialogue(dialogue_id)
	var nodes: Dictionary = dialogue.get("nodes", {})
	return nodes.get(node_id, {})

static func get_start_node(dialogue_id: String) -> String:
	var dialogue := get_dialogue(dialogue_id)
	var nodes: Dictionary = dialogue.get("nodes", {})
	if nodes.has("start"):
		return "start"
	return ""

static func evaluate_conditions(node: Dictionary, world_flags: Dictionary) -> bool:
	var req_flag: String = node.get("require_flag", "")
	if req_flag != "" and not world_flags.get(req_flag, false):
		return false
	return true

static func filter_choices(choices: Array, world_flags: Dictionary) -> Array:
	var filtered: Array = []
	for choice in choices:
		var cond: String = choice.get("condition", "")
		if cond != "" and not world_flags.get(cond, false):
			continue
		filtered.append(choice)
	return filtered

static func apply_effects(effects: Dictionary, game_manager: Node) -> void:
	if effects.is_empty():
		return
	var flag: String = effects.get("set_flag", "")
	if flag != "":
		game_manager.set_world_flag(flag, true)
	var xp: float = effects.get("xp", 0.0)
	if xp > 0.0:
		game_manager.add_xp(xp)
	var credits: int = effects.get("credits", 0)
	if credits > 0:
		game_manager.add_currency(credits)

static func has_dialogue(npc_name: String) -> bool:
	return NPC_DIALOGUES.has(npc_name)

static func get_all_dialogue_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in DIALOGUES.keys():
		ids.append(key)
	return ids
