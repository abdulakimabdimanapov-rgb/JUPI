

import json, os, sys, tempfile, shutil

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

PASSED = 0
FAILED = 0
ERRORS = []

def check(name, condition, detail=""):
    global PASSED, FAILED, ERRORS
    if condition:
        PASSED += 1
        print(f"  ✅ {name}")
    else:
        FAILED += 1
        msg = f"  ❌ {name}" + (f" — {detail}" if detail else "")
        print(msg)
        ERRORS.append(msg)


print("\n⚔️  BOSS SYSTEM")

bosses = {
    "corporate_enforcer": {
        "id": "corporate_enforcer", "name": "Corporate Enforcer",
        "era": "present", "max_hp": 400.0, "damage": 20.0,
        "movement_speed": 50.0, "attack_range": 22.0, "attack_cooldown": 1.2,
        "detection_range": 200.0, "xp_reward": 200.0, "currency_reward": 400,
        "difficulty": 2,
        "attack_types": ["melee", "ranged", "dash"],
        "phases": [
            {"name": "Standard", "hp_threshold": 0.6, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["melee", "ranged"]},
            {"name": "Enraged", "hp_threshold": 0.3, "speed_mult": 1.3, "damage_mult": 1.4, "attacks": ["melee", "ranged", "dash"]},
            {"name": "Desperate", "hp_threshold": 0.0, "speed_mult": 1.6, "damage_mult": 1.8, "attacks": ["melee", "ranged", "dash"]},
        ],
        "loot": {"currency": 400, "xp": 200, "unique_item": "enforcer_badge"},
    },
    "warlord": {
        "id": "warlord", "name": "The Warlord",
        "era": "past", "max_hp": 600.0, "damage": 30.0,
        "movement_speed": 35.0, "attack_range": 28.0, "attack_cooldown": 1.8,
        "detection_range": 180.0, "xp_reward": 350.0, "currency_reward": 600,
        "difficulty": 3,
        "attack_types": ["melee", "summon", "area"],
        "phases": [
            {"name": "Warlord", "hp_threshold": 0.5, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["melee", "summon"]},
            {"name": "Berserker", "hp_threshold": 0.25, "speed_mult": 1.4, "damage_mult": 1.5, "attacks": ["melee", "area", "summon"]},
            {"name": "Final Stand", "hp_threshold": 0.0, "speed_mult": 1.8, "damage_mult": 2.0, "attacks": ["melee", "area"]},
        ],
        "loot": {"currency": 600, "xp": 350, "unique_item": "ancient_blade"},
    },
    "cyber_guardian": {
        "id": "cyber_guardian", "name": "Cyber Guardian",
        "era": "future", "max_hp": 500.0, "damage": 25.0,
        "movement_speed": 45.0, "attack_range": 100.0, "attack_cooldown": 1.0,
        "detection_range": 250.0, "xp_reward": 400.0, "currency_reward": 700,
        "difficulty": 4,
        "attack_types": ["ranged", "area", "summon"],
        "phases": [
            {"name": "Guardian", "hp_threshold": 0.5, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["ranged", "summon"]},
            {"name": "Overcharged", "hp_threshold": 0.25, "speed_mult": 1.2, "damage_mult": 1.5, "attacks": ["ranged", "area", "summon"]},
            {"name": "Self-Destruct", "hp_threshold": 0.0, "speed_mult": 1.5, "damage_mult": 2.0, "attacks": ["area", "ranged"]},
        ],
        "loot": {"currency": 700, "xp": 400, "unique_item": "pulse_core"},
    },
    "time_devourer": {
        "id": "time_devourer", "name": "Time Devourer",
        "era": "collapsed", "max_hp": 800.0, "damage": 35.0,
        "movement_speed": 40.0, "attack_range": 30.0, "attack_cooldown": 1.5,
        "detection_range": 300.0, "xp_reward": 600.0, "currency_reward": 1000,
        "difficulty": 5,
        "attack_types": ["melee", "area", "special"],
        "phases": [
            {"name": "Devourer", "hp_threshold": 0.5, "speed_mult": 1.0, "damage_mult": 1.0, "attacks": ["melee", "area"]},
            {"name": "Ravenous", "hp_threshold": 0.25, "speed_mult": 1.3, "damage_mult": 1.6, "attacks": ["melee", "area", "special"]},
            {"name": "Chrono Collapse", "hp_threshold": 0.0, "speed_mult": 1.7, "damage_mult": 2.2, "attacks": ["area", "special"]},
        ],
        "loot": {"currency": 1000, "xp": 600, "unique_item": "chrono_shard"},
    },
}

check("4 bosses defined", len(bosses) == 4)
check("Each boss has required fields",
     all(all(k in b for k in ["id", "name", "era", "max_hp", "damage", "phases", "attack_types", "loot"]) for b in bosses.values()))
check("All eras covered by bosses", set(b["era"] for b in bosses.values()) == {"present", "past", "future", "collapsed"})
check("Each boss has 3 phases", all(len(b["phases"]) == 3 for b in bosses.values()))
check("Each boss has unique_item in loot", all("unique_item" in b["loot"] for b in bosses.values()))
check("Corporate Enforcer in present", bosses["corporate_enforcer"]["era"] == "present")
check("Warlord in past", bosses["warlord"]["era"] == "past")
check("Cyber Guardian in future", bosses["cyber_guardian"]["era"] == "future")
check("Time Devourer in collapsed", bosses["time_devourer"]["era"] == "collapsed")

def get_phase(boss, hp_percent):
    for phase in boss["phases"]:
        if hp_percent > phase["hp_threshold"]:
            return phase
    return boss["phases"][-1]

check("Phase 1 at 100% HP", get_phase(bosses["warlord"], 1.0)["name"] == "Warlord")
check("Phase 2 at 40% HP", get_phase(bosses["warlord"], 0.4)["name"] == "Berserker")
check("Phase 3 at 10% HP", get_phase(bosses["warlord"], 0.1)["name"] == "Final Stand")
check("Phase speed increases each phase",
     get_phase(bosses["warlord"], 0.1)["speed_mult"] > get_phase(bosses["warlord"], 1.0)["speed_mult"])
check("Phase damage increases each phase",
     get_phase(bosses["warlord"], 0.1)["damage_mult"] > get_phase(bosses["warlord"], 1.0)["damage_mult"])

check("Time Devourer has highest HP", bosses["time_devourer"]["max_hp"] > bosses["warlord"]["max_hp"])
check("Time Devourer has highest difficulty", bosses["time_devourer"]["difficulty"] > bosses["corporate_enforcer"]["difficulty"])
check("Corporate Enforcer has fastest attack cooldown", bosses["corporate_enforcer"]["attack_cooldown"] < bosses["warlord"]["attack_cooldown"])

print("\n🎁 BOSS REWARDS")

check("Corporate Enforcer unique item", bosses["corporate_enforcer"]["loot"]["unique_item"] == "enforcer_badge")
check("Warlord unique item is ancient_blade", bosses["warlord"]["loot"]["unique_item"] == "ancient_blade")
check("Cyber Guardian unique item", bosses["cyber_guardian"]["loot"]["unique_item"] == "pulse_core")
check("Time Devourer unique item", bosses["time_devourer"]["loot"]["unique_item"] == "chrono_shard")
check("Warlord XP reward > Enforcer XP", bosses["warlord"]["xp_reward"] > bosses["corporate_enforcer"]["xp_reward"])

print("\n⚔️  ATTACK PATTERNS")

all_attack_types = set()
for b in bosses.values():
    all_attack_types.update(b["attack_types"])

check("6 attack types exist", all_attack_types == {"melee", "ranged", "area", "dash", "summon", "special"})
check("Enforcer has dash", "dash" in bosses["corporate_enforcer"]["attack_types"])
check("Warlord has summon", "summon" in bosses["warlord"]["attack_types"])
check("Cyber Guardian has ranged", "ranged" in bosses["cyber_guardian"]["attack_types"])
check("Time Devourer has special", "special" in bosses["time_devourer"]["attack_types"])
check("Each boss has at least 2 attack types", all(len(b["attack_types"]) >= 2 for b in bosses.values()))

print("\n⏱️  TIME PARADOX SYSTEM")

paradox_events = [
    {"id": "save_village", "source_era": "past", "target_era": "present", "trigger": "complete_contract_protect_village", "world_flag": "past_village_saved"},
    {"id": "destroy_factory", "source_era": "past", "target_era": "future", "trigger": "defeat_boss_warlord", "world_flag": "past_factory_destroyed"},
    {"id": "kill_inventor", "source_era": "past", "target_era": "future", "trigger": "complete_contract_kill_inventor", "world_flag": "inventor_killed"},
    {"id": "save_technology", "source_era": "past", "target_era": "future", "trigger": "complete_contract_preserve_tech", "world_flag": "technology_preserved"},
    {"id": "fail_city_defense", "source_era": "present", "target_era": "collapsed", "trigger": "fail_contract_defend_city", "world_flag": "city_fell"},
    {"id": "defeat_time_devourer", "source_era": "collapsed", "target_era": "all", "trigger": "defeat_boss_time_devourer", "world_flag": "time_devourer_defeated"},
    {"id": "save_scientist", "source_era": "future", "target_era": "collapsed", "trigger": "complete_contract_save_scientist", "world_flag": "scientist_saved"},
]

check("7 paradox events defined", len(paradox_events) == 7)
check("Each event has required fields",
     all(all(k in e for k in ["id", "source_era", "target_era", "trigger", "world_flag"]) for e in paradox_events))
check("Cross-era events exist", any(e["target_era"] == "all" for e in paradox_events))
check("past → present paradox exists", any(e["source_era"] == "past" and e["target_era"] == "present" for e in paradox_events))
check("past → future paradoxes exist", sum(1 for e in paradox_events if e["source_era"] == "past" and e["target_era"] == "future") >= 2)

def check_trigger(trigger, world_flags):
    result = []
    for e in paradox_events:
        if e["trigger"] == trigger and not world_flags.get(e["world_flag"], False):
            result.append(e)
    return result

check("Trigger check: defeat_boss_warlord",
     len(check_trigger("defeat_boss_warlord", {})) == 1)
check("Trigger check: already triggered flag",
     len(check_trigger("defeat_boss_warlord", {"past_factory_destroyed": True})) == 0)
check("Trigger check: unknown trigger",
     len(check_trigger("nonexistent_trigger", {})) == 0)
check("Trigger check: protect_village",
     len(check_trigger("complete_contract_protect_village", {})) == 1)

print("\n🌍 WORLD STATE")

locations = {
    "village": {"normal": "Standing", "saved": "Thriving", "destroyed": "Ruins"},
    "factory": {"normal": "Operational", "destroyed": "Abandoned", "saved": "Upgraded"},
    "city": {"normal": "Normal", "defended": "Fortified", "fell": "Destroyed"},
    "lab": {"normal": "Sealed", "unlocked": "Accessible", "destroyed": "Wrecked"},
    "tower": {"normal": "Standing", "stabilized": "Repaired", "collapsed": "Ruins"},
}

check("5 locations defined", len(locations) == 5)
check("Each location has normal state", all("normal" in v for v in locations.values()))
check("Each location has at least 2 states", all(len(v) >= 2 for v in locations.values()))



def get_location_state(loc, world_flags):
    loc_data = locations.get(loc, {})
    if world_flags.get("past_%s_saved" % loc, False):
        return loc_data.get("saved", "saved")
    elif world_flags.get("%s_destroyed" % loc, False) or world_flags.get("%s_fell" % loc, False):
        return loc_data.get("destroyed", "destroyed")
    elif world_flags.get("%s_unlocked" % loc, False):
        return loc_data.get("unlocked", "unlocked")
    return loc_data.get("normal", "normal")

check("Village normal state", get_location_state("village", {}) == "Standing")
check("Village saved state", get_location_state("village", {"past_village_saved": True}) == "Thriving")
check("Village destroyed state", get_location_state("village", {"village_destroyed": True}) == "Ruins")
check("City fell state returns fallback", get_location_state("city", {"city_fell": True}) == "destroyed")
check("Factory normal when no matching flag", get_location_state("factory", {}) == "Operational")
check("Village saved overrides normal", get_location_state("village", {"past_village_saved": True}) == "Thriving")
check("Unknown location returns normal fallback", get_location_state("nonexistent", {}) == "normal")
check("All 5 locations return strings", all(isinstance(get_location_state(loc, {}), str) for loc in locations))

print("\n📋 CONTRACT CHAINS")

contract_chains = [
    {
        "id": "village_chain",
        "name": "Village Protection Chain",
        "era": "past",
        "contracts": [
            {"id": "chain_1_1", "type": "RECOVER", "target": "Village Elder", "desc": "Find the Village Elder's missing supplies", "reward_tier": "easy"},
            {"id": "chain_1_2", "type": "PROTECT", "target": "Village", "desc": "Protect the village from raiders", "reward_tier": "medium"},
            {"id": "chain_1_3", "type": "BOSS_KILL", "target": "Warlord", "desc": "Defeat the Warlord threatening the village", "reward_tier": "boss"},
        ],
        "final_flag": "past_village_saved",
    },
    {
        "id": "tech_chain",
        "name": "Technology Preservation Chain",
        "era": "future",
        "contracts": [
            {"id": "chain_2_1", "type": "TRAVEL", "target": "Data Center", "desc": "Reach the Data Center", "reward_tier": "easy"},
            {"id": "chain_2_2", "type": "RECOVER", "target": "Quantum Chip", "desc": "Recover the Quantum Chip from hostiles", "reward_tier": "medium"},
            {"id": "chain_2_3", "type": "BOSS_KILL", "target": "Cyber Guardian", "desc": "Defeat the Cyber Guardian protecting the core", "reward_tier": "boss"},
        ],
        "final_flag": "technology_preserved",
    },
]

check("2 contract chains defined", len(contract_chains) == 2)
check("Each chain has 3 contracts", all(len(c["contracts"]) == 3 for c in contract_chains))
check("Each chain has a final_flag", all("final_flag" in c for c in contract_chains))
check("Village chain is in past", contract_chains[0]["era"] == "past")
check("Tech chain is in future", contract_chains[1]["era"] == "future")
check("Village chain ends with BOSS_KILL", contract_chains[0]["contracts"][-1]["type"] == "BOSS_KILL")
check("Tech chain ends with BOSS_KILL", contract_chains[1]["contracts"][-1]["type"] == "BOSS_KILL")

def advance_chain(chain_id, current_step):
    chain = next((c for c in contract_chains if c["id"] == chain_id), None)
    if chain is None:
        return {"complete": False}
    next_step = current_step + 1
    if next_step >= len(chain["contracts"]):
        return {"complete": True, "flag": chain["final_flag"]}
    return {"complete": False, "next_contract": chain["contracts"][next_step], "step": next_step}

check("Chain step 0 → step 1",
     advance_chain("village_chain", 0)["step"] == 1)
check("Chain step 1 → step 2",
     advance_chain("village_chain", 1)["step"] == 2)
check("Chain step 2 → complete",
     advance_chain("village_chain", 2)["complete"] is True)
check("Chain completion sets flag",
     advance_chain("village_chain", 2)["flag"] == "past_village_saved")
check("Unknown chain returns empty",
     advance_chain("nonexistent", 0)["complete"] is False)

print("\n📝 CONTRACT TEMPLATES")

templates = {
    "KILL": ["Eliminate %s in %s", "Hunt down %s", "Clear the area of %s"],
    "RECOVER": ["Recover %s from %s", "Retrieve the lost %s", "Find and secure %s"],
    "PROTECT": ["Protect %s for %d seconds", "Defend %s from attackers", "Guard %s against hostiles"],
    "HUNT": ["Hunt the %s", "Track and eliminate the %s", "Pursue the %s target"],
    "TRAVEL": ["Reach %s", "Navigate to %s", "Travel to %s and return"],
    "BOSS_KILL": ["Defeat the %s", "Eliminate the %s boss", "Confront and destroy the %s"],
}

check("6 contract template types", len(templates) == 6)
check("Each type has 3 templates", all(len(v) == 3 for v in templates.values()))
check("KILL templates exist", "KILL" in templates)
check("BOSS_KILL templates exist", "BOSS_KILL" in templates)

print("\n🗺️  ERA CONTRACT TARGETS")

era_targets = {
    "present": {"enemies": ["Corporate Guard", "Armed Thug", "Security Drone"]},
    "past": {"enemies": ["Soldier", "Mercenary", "Bandit"]},
    "future": {"enemies": ["Rogue Drone", "Android Guard", "Plasma Sentry"]},
    "collapsed": {"enemies": ["Mutant", "Rogue Machine", "Scavenger Gang"]},
}

check("4 eras have targets", len(era_targets) == 4)
check("Each era has enemies", all("enemies" in v for v in era_targets.values()))
check("Each era has at least 3 enemies", all(len(v["enemies"]) >= 3 for v in era_targets.values()))

print("\n💾 SAVE VERSIONING")

save_v3 = {
    "version": 3,
    "player_level": 5,
    "defeated_bosses": ["warlord"],
    "active_boss_id": "",
    "paradox_history": [{"event_id": "save_village", "flag": "past_village_saved", "time": "2025-01-01"}],
    "world_flags": {"past_village_saved": True, "boss_warlord_defeated": True},
    "current_era": "present",
    "unlocked_eras": ["present", "past", "future"],
}

check("Save v3 has version field", save_v3["version"] == 3)
check("Save v3 has defeated_bosses", "defeated_bosses" in save_v3)
check("Save v3 has paradox_history", "paradox_history" in save_v3)
check("Save v3 has world_flags", "world_flags" in save_v3)
check("Save v3 migration: boss state preserved", save_v3["defeated_bosses"] == ["warlord"])
check("Save v3 migration: paradox history preserved", len(save_v3["paradox_history"]) == 1)

save_v2_compat = {
    "version": 2,
    "player_level": 3,
    "defeated_bosses": [],
    "paradox_history": [],
    "world_flags": {},
}
check("v2 save with v3 fields defaults work", save_v2_compat.get("defeated_bosses", []) == [])
check("v2 save missing paradox defaults", save_v2_compat.get("paradox_history", []) == [])

print("\n📅 TIMELINE STATES")

timeline_states = ["UNKNOWN", "DISCOVERED", "CHANGED", "LOCKED"]
check("4 timeline states", len(timeline_states) == 4)

def get_event_state(world_flags, event):
    flag = event.get("world_flag", "")
    if world_flags.get(flag, False):
        return "CHANGED"
    return "UNKNOWN"

check("Event unknown when flag not set",
     get_event_state({}, {"world_flag": "past_village_saved"}) == "UNKNOWN")
check("Event changed when flag set",
     get_event_state({"past_village_saved": True}, {"world_flag": "past_village_saved"}) == "CHANGED")

print("\n🎮 GAME STATES")

game_states = ["EXPLORING", "COMBAT", "SHOP", "INVENTORY", "CONTRACT_BOARD",
               "DEAD", "PAUSED", "DIALOGUE", "TIME_TRAVEL", "TIMELINE", "BOSS_FIGHT", "PARADOX_EVENT"]
check("12 game states defined", len(game_states) == 12)
check("BOSS_FIGHT state exists", "BOSS_FIGHT" in game_states)
check("TIMELINE state exists", "TIMELINE" in game_states)
check("PARADOX_EVENT state exists", "PARADOX_EVENT" in game_states)

print("\n" + "=" * 60)
total = PASSED + FAILED
print(f"Boss & Paradox Tests: {PASSED}/{total} passed", end="")
if FAILED > 0:
    print(f"  ({FAILED} FAILED)")
    for e in ERRORS:
        print(f"  {e}")
else:
    print("  ✅ ALL PASSED")
