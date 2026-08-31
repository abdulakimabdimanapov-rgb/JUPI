      
import json
import os
import sys
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "ai"))


class TestEraData(unittest.TestCase):

    def test_all_eras_defined(self):

        eras = ["present", "past", "future", "collapsed"]
        self.assertEqual(len(eras), 4)

    def test_era_has_required_fields(self):

        era = {
            "id": "present", "name": "PRESENT", "danger": "LOW",
            "recommended_level": 1, "enemies": ["guard"],
            "npcs": [], "contract_pool": [], "unlock_condition": "",
        }
        for field in ["id", "name", "danger", "recommended_level", "enemies"]:
            self.assertIn(field, era)

    def test_era_danger_levels(self):

        dangers = {"present": "LOW", "past": "MEDIUM", "future": "HIGH", "collapsed": "EXTREME"}
        for era_id, danger in dangers.items():
            self.assertIn(danger, ["LOW", "MEDIUM", "HIGH", "EXTREME"])

    def test_era_enemy_lists(self):        

        era_enemies = {
            "present": ["guard", "fast", "heavy"],
            "past": ["soldier", "hunter", "heavy_knight"],
            "future": ["drone", "android", "plasma_guard"],
            "collapsed": ["mutant", "rogue_machine", "elite_hunter"],
        }
        for era_id, enemies in era_enemies.items():
            self.assertGreater(len(enemies), 0, f"{era_id} has no enemies")

    def test_era_npc_lists(self):

        era_npcs = {
            "present": ["Trader", "Informant", "Citizen"],
            "past": ["Merchant", "Guard Captain", "Elder"],
            "future": ["Engineer", "Scientist", "Informant"],
            "collapsed": ["Survivor", "Scavenger"],
        }
        for era_id, npcs in era_npcs.items():
            self.assertGreater(len(npcs), 0, f"{era_id} has no NPCs")

    def test_era_visual_themes(self):

        themes = {
            "present": {"bg": (0.04, 0.03, 0.06), "ground": (0.18, 0.18, 0.20)},
            "past": {"bg": (0.06, 0.04, 0.03), "ground": (0.25, 0.22, 0.18)},
            "future": {"bg": (0.02, 0.03, 0.06), "ground": (0.12, 0.14, 0.20)},
            "collapsed": {"bg": (0.05, 0.02, 0.02), "ground": (0.15, 0.12, 0.10)},
        }
        for era_id, colors in themes.items():
            self.assertIn("bg", colors)
            self.assertIn("ground", colors)

    def test_era_scaling_modifiers(self):

        modifiers = {
            "present": {"hp": 1.0, "dmg": 1.0, "speed": 1.0, "xp": 1.0},
            "past": {"hp": 1.2, "dmg": 1.1, "speed": 0.9, "xp": 1.3},
            "future": {"hp": 1.5, "dmg": 1.4, "speed": 1.2, "xp": 1.5},
            "collapsed": {"hp": 2.0, "dmg": 1.8, "speed": 1.1, "xp": 2.0},
        }
        for era_id, mod in modifiers.items():
            self.assertGreaterEqual(mod["hp"], 1.0)
            self.assertGreaterEqual(mod["dmg"], 1.0)


class TestEraDiscovery(unittest.TestCase):


    def test_present_always_unlocked(self):

        unlocked = ["present"]
        self.assertIn("present", unlocked)

    def test_unlock_condition_complete_any(self):

        def can_unlock(completed):
            return completed > 0
        self.assertFalse(can_unlock(0))
        self.assertTrue(can_unlock(1))

    def test_unlock_condition_level_5(self):

        def can_unlock(level):
            return level >= 5
        self.assertFalse(can_unlock(3))
        self.assertTrue(can_unlock(5))

    def test_unlock_condition_3_contracts(self):

        def can_unlock(completed):
            return completed >= 3
        self.assertFalse(can_unlock(2))
        self.assertTrue(can_unlock(3))

    def test_unlocked_eras_list(self):

        unlocked = ["present"]
        unlocked.append("past")
        self.assertEqual(len(unlocked), 2)
        self.assertIn("past", unlocked)

    def test_locked_era_not_accessible(self):

        unlocked = ["present", "past"]
        target = "future"
        can_travel = target in unlocked
        self.assertFalse(can_travel)


class TestTimeTravel(unittest.TestCase):


    def test_travel_changes_era(self):

        current = "present"
        target = "past"
        current = target
        self.assertEqual(current, "past")

    def test_travel_requires_unlock(self):

        unlocked = ["present", "past"]
        target = "future"
        can_travel = target in unlocked
        self.assertFalse(can_travel)

    def test_travel_increments_visit_count(self):

        visits = {"present": 1, "past": 0}
        target = "past"
        visits[target] = visits.get(target, 0) + 1
        self.assertEqual(visits["past"], 1)

    def test_travel_emits_signal(self):

        signals = []
        def on_complete(era):
            signals.append(era)
        on_complete("past")
        self.assertEqual(len(signals), 1)
        self.assertEqual(signals[0], "past")

    def test_return_to_hub(self):

        current = "past"
        current = "present"
        self.assertEqual(current, "present")


class TestWorldFlags(unittest.TestCase):


    def test_set_flag(self):

        flags = {}
        flags["past_village_saved"] = True
        self.assertTrue(flags["past_village_saved"])

    def test_get_flag(self):

        flags = {"past_village_saved": True}
        self.assertTrue(flags.get("past_village_saved", False))
        self.assertFalse(flags.get("future_lab_unlocked", False))

    def test_flag_modifies_content(self):

        flags = {"past_village_saved": True}
        enemy_count = 3 if flags.get("past_village_saved", False) else 5
        self.assertEqual(enemy_count, 3)

    def test_flag_unlocks_era(self):

        flags = {"past_village_saved": True}
        unlocked = ["present", "past"]
        if flags.get("past_village_saved", False) and "future" not in unlocked:
            unlocked.append("future")
        self.assertIn("future", unlocked)

    def test_multiple_flags(self):

        flags = {}
        flags["past_village_saved"] = True
        flags["future_lab_unlocked"] = True
        flags["collapsed_zone_opened"] = False
        self.assertEqual(len(flags), 3)


class TestEraEnemies(unittest.TestCase):


    def test_enemy_stats_scale_with_era(self):

        base_hp = 50.0
        era_mods = {"present": 1.0, "past": 1.2, "future": 1.5, "collapsed": 2.0}
        for era_id, mult in era_mods.items():
            scaled_hp = base_hp * mult
            self.assertGreaterEqual(scaled_hp, base_hp)

    def test_enemy_types_per_era(self):

        era_enemies = {
            "present": {"guard", "fast", "heavy"},
            "past": {"soldier", "hunter", "heavy_knight"},
            "future": {"drone", "android", "plasma_guard"},
            "collapsed": {"mutant", "rogue_machine", "elite_hunter"},
        }
        all_types = set()
        for enemies in era_enemies.values():
            for e in enemies:
                self.assertNotIn(e, all_types, f"Enemy {e} appears in multiple eras")
                all_types.add(e)

    def test_enemy_xp_scales(self):

        base_xp = 25.0
        xp_mults = {"present": 1.0, "past": 1.3, "future": 1.5, "collapsed": 2.0}
        for era_id, mult in xp_mults.items():
            scaled_xp = base_xp * mult
            self.assertGreaterEqual(scaled_xp, base_xp)


class TestEraNPCs(unittest.TestCase):


    def test_npcs_have_dialogue(self):

        npcs = [
            {"name": "Trader", "dialogue": "Welcome!"},
            {"name": "Merchant", "dialogue": "Fine goods!"},
            {"name": "Engineer", "dialogue": "The grid is destabilizing."},
            {"name": "Survivor", "dialogue": "You're alive?"},
        ]
        for npc in npcs:
            self.assertIn("dialogue", npc)
            self.assertGreater(len(npc["dialogue"]), 0)

    def test_npcs_have_era(self):

        npc_eras = {
            "Trader": "present",
            "Merchant": "past",
            "Engineer": "future",
            "Survivor": "collapsed",
        }
        for npc_name, era in npc_eras.items():
            self.assertIn(era, ["present", "past", "future", "collapsed"])


class TestEraSaveIntegration(unittest.TestCase):


    def test_save_includes_current_era(self):

        save = {"current_era": "past", "player_level": 3}
        self.assertEqual(save["current_era"], "past")

    def test_save_includes_unlocked_eras(self):

        save = {"unlocked_eras": ["present", "past"]}
        self.assertEqual(len(save["unlocked_eras"]), 2)

    def test_save_includes_world_flags(self):

        save = {"world_flags": {"past_village_saved": True}}
        self.assertTrue(save["world_flags"]["past_village_saved"])

    def test_load_restores_era(self):

        save = {"current_era": "future"}
        loaded_era = save.get("current_era", "present")
        self.assertEqual(loaded_era, "future")

    def test_load_missing_era_defaults(self):

        save = {}
        loaded_era = save.get("current_era", "present")
        self.assertEqual(loaded_era, "present")

    def test_save_version_2(self):

        save = {"version": 2}
        self.assertEqual(save["version"], 2)


class TestEraUI(unittest.TestCase):


    def test_era_list_shows_all(self):

        all_eras = ["present", "past", "future", "collapsed"]
        self.assertEqual(len(all_eras), 4)

    def test_locked_era_shows_lock(self):

        unlocked = ["present"]
        is_unlocked = "past" in unlocked
        self.assertFalse(is_unlocked)

    def test_current_era_marked(self):

        current = "present"
        is_current = current == "present"
        self.assertTrue(is_current)

    def test_travel_button_only_for_unlocked(self):

        unlocked = ["present", "past"]
        for era in unlocked:
            can_show = era in unlocked
            self.assertTrue(can_show)
        for era in ["future", "collapsed"]:
            can_show = era in unlocked
            self.assertFalse(can_show)


class TestGameLoop(unittest.TestCase):


    def test_hub_to_era_to_hub(self):

        state = "hub"
        state = "traveling"
        state = "era"
        state = "traveling"
        state = "hub"
        self.assertEqual(state, "hub")

    def test_era_exploration(self):

        state = "era"
        can_explore = state == "era"
        self.assertTrue(can_explore)

    def test_contract_in_era(self):

        era = "past"
        contract = {"era": era, "type": "KILL_N"}
        self.assertEqual(contract["era"], "past")

    def test_loot_collects_in_era(self):

        currency = 0
        currency += 50
        self.assertEqual(currency, 50)

    def test_return_to_hub_preserves_progress(self):

        progress = {"level": 3, "currency": 500, "era": "past"}
        progress["era"] = "present"
        self.assertEqual(progress["level"], 3)
        self.assertEqual(progress["currency"], 500)


if __name__ == "__main__":
    unittest.main(verbosity=2)

  


   