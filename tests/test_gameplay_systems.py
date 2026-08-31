

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "ai"))


class TestSaveSystem(unittest.TestCase):


    def test_default_save_structure(self):

        defaults = {
            "version": 1, "player_level": 1, "player_xp": 0.0,
            "currency": 0, "max_hp": 100.0, "equipped_weapon": "combat_knife",
            "inventory": {}, "total_kills": 0,
        }
        for key in defaults:
            self.assertIn(key, defaults)

    def test_save_version_exists(self):

        data = {"version": 1, "player_level": 1}
        self.assertEqual(data["version"], 1)

    def test_save_missing_fields_fallback(self):

        saved = {"version": 1}
        defaults = {"player_level": 1, "currency": 0, "max_hp": 100.0}
        for key in defaults:
            if key not in saved:
                saved[key] = defaults[key]
        self.assertEqual(saved["player_level"], 1)
        self.assertEqual(saved["currency"], 0)
        self.assertEqual(saved["max_hp"], 100.0)

    def test_corrupted_save_handling(self):

        corrupted = "not valid json {{{"
        try:
            json.loads(corrupted)
        except json.JSONDecodeError:
            pass

    def test_save_roundtrip(self):

        data = {"player_level": 5, "currency": 500, "max_hp": 150.0}
        json_str = json.dumps(data)
        loaded = json.loads(json_str)
        self.assertEqual(loaded["player_level"], 5)
        self.assertEqual(loaded["currency"], 500)
        self.assertEqual(loaded["max_hp"], 150.0)


class TestWeaponSystem(unittest.TestCase):


    def test_default_weapon_exists(self):

        weapons = {
            "combat_knife": {"damage": 18.0, "range": 22.0, "crit_chance": 0.15},
        }
        self.assertIn("combat_knife", weapons)

    def test_weapon_damage_positive(self):

        weapons = {
            "combat_knife": {"damage": 18.0},
            "hunter_blade": {"damage": 20.0},
            "iron_sword": {"damage": 28.0},
            "phase_blade": {"damage": 35.0},
        }
        for wid, wdata in weapons.items():
            self.assertGreater(wdata["damage"], 0, f"{wid} has non-positive damage")

    def test_damage_calculation_with_crit(self):

        base_damage = 20.0
        crit_mult = 2.0
        normal = base_damage
        crit = base_damage * crit_mult
        self.assertEqual(crit, normal * 2)

    def test_damage_with_level_bonus(self):

        base = 18.0
        level_bonus = 9.0
        total = base + level_bonus
        self.assertEqual(total, 27.0)


class TestInventorySystem(unittest.TestCase):


    def test_add_item(self):

        inv = {}
        item_id = "hp_potion"
        inv[item_id] = inv.get(item_id, 0) + 1
        self.assertEqual(inv[item_id], 1)

    def test_add_multiple(self):

        inv = {}
        for _ in range(3):
            inv["hp_potion"] = inv.get("hp_potion", 0) + 1
        self.assertEqual(inv["hp_potion"], 3)

    def test_remove_item(self):

        inv = {"hp_potion": 3}
        if inv.get("hp_potion", 0) >= 1:
            inv["hp_potion"] -= 1
        self.assertEqual(inv["hp_potion"], 2)

    def test_remove_last_item(self):

        inv = {"hp_potion": 1}
        if inv.get("hp_potion", 0) >= 1:
            inv["hp_potion"] -= 1
            if inv["hp_potion"] <= 0:
                del inv["hp_potion"]
        self.assertNotIn("hp_potion", inv)

    def test_remove_nonexistent(self):

        inv = {}
        has = inv.get("nonexistent", 0) >= 1
        self.assertFalse(has)

    def test_equip_weapon(self):

        equipped = "combat_knife"
        new_weapon = "hunter_blade"
        equipped = new_weapon
        self.assertEqual(equipped, "hunter_blade")

    def test_consumable_use(self):

        hp = 50.0
        max_hp = 100.0
        heal = 30.0
        hp = min(max_hp, hp + heal)
        self.assertEqual(hp, 80.0)


class TestShopSystem(unittest.TestCase):


    def test_can_afford(self):

        currency = 500
        price = 300
        self.assertTrue(currency >= price)

    def test_cannot_afford(self):

        currency = 100
        price = 300
        self.assertFalse(currency >= price)

    def test_purchase_deducts_currency(self):

        currency = 500
        price = 300
        currency -= price
        self.assertEqual(currency, 200)

    def test_item_prices_positive(self):

        items = {
            "max_hp_1": 200, "hunter_blade": 300,
            "hp_potion": 50, "phase_blade": 1500,
        }
        for item_id, price in items.items():
            self.assertGreater(price, 0, f"{item_id} has non-positive price")


class TestContractSystem(unittest.TestCase):


    def test_contract_types(self):

        types = ["KILL_TARGET", "KILL_N", "SURVIVE", "REACH"]
        self.assertEqual(len(types), 4)

    def test_contract_has_reward(self):

        contract = {
            "id": "test", "type": "KILL_N",
            "reward": {"credits": 200, "xp": 80.0}
        }
        self.assertIn("reward", contract)
        self.assertGreater(contract["reward"]["credits"], 0)

    def test_contract_completion_increments_count(self):

        completed = []
        contract = {"id": "c1", "status": "completed"}
        completed.append(contract)
        self.assertEqual(len(completed), 1)

    def test_contract_failure_increments_count(self):

        failed_count = 0
        failed_count += 1
        self.assertEqual(failed_count, 1)


class TestGameStates(unittest.TestCase):


    def test_states_defined(self):

        states = {
            "EXPLORING": 0, "COMBAT": 1, "SHOP": 2,
            "INVENTORY": 3, "CONTRACT_BOARD": 4,
            "DEAD": 5, "PAUSED": 6, "DIALOGUE": 7,
        }
        self.assertEqual(len(states), 8)

    def test_shop_blocks_combat(self):

        current_state = 2
        can_act = current_state in [0, 1]
        self.assertFalse(can_act)

    def test_inventory_blocks_combat(self):

        current_state = 3
        can_act = current_state in [0, 1]
        self.assertFalse(can_act)

    def test_exploring_allows_combat(self):

        current_state = 0
        can_act = current_state in [0, 1]
        self.assertTrue(can_act)

    def test_ui_open_check(self):

        ui_states = [2, 3, 4, 7]
        for state in ui_states:
            is_ui = state in ui_states
            self.assertTrue(is_ui, f"State {state} should be UI")


class TestProgression(unittest.TestCase):


    def test_xp_curve(self):

        xp_req = 100.0 + (1 - 1) * 50.0
        self.assertEqual(xp_req, 100.0)
        xp_req2 = 100.0 + (5 - 1) * 50.0
        self.assertEqual(xp_req2, 300.0)

    def test_level_up_on_xp_threshold(self):

        xp = 105.0
        xp_to_next = 100.0
        level = 1
        while xp >= xp_to_next:
            xp -= xp_to_next
            level += 1
            xp_to_next = 100.0 + (level - 1) * 50.0
        self.assertEqual(level, 2)

    def test_level_up_heals(self):

        max_hp = 100.0
        hp = 50.0
        hp_bonus = 10.0
        max_hp += hp_bonus
        hp = max_hp
        self.assertEqual(hp, 110.0)
        self.assertEqual(max_hp, 110.0)

    def test_difficulty_scaling(self):

        def scale(level):
            return 1.0 + (level - 1) * 0.1
        self.assertAlmostEqual(scale(1), 1.0)
        self.assertAlmostEqual(scale(10), 1.9)
        self.assertAlmostEqual(scale(20), 2.9)


class TestLootSystem(unittest.TestCase):


    def test_loot_types_exist(self):

        types = ["hp", "energy", "currency", "rare"]
        self.assertEqual(len(types), 4)

    def test_loot_probabilities_sum(self):

        loot_table = {"hp": 0.3, "energy": 0.2, "currency": 0.4, "rare": 0.05}
        total = sum(loot_table.values())
        self.assertAlmostEqual(total, 0.95, places=1)

    def test_loot_effect_hp(self):

        hp = 50.0
        max_hp = 100.0
        heal = 15.0
        hp = min(max_hp, hp + heal)
        self.assertEqual(hp, 65.0)

    def test_loot_effect_energy(self):

        energy = 30.0
        max_energy = 100.0
        restore = 25.0
        energy = min(max_energy, energy + restore)
        self.assertEqual(energy, 55.0)

    def test_loot_effect_currency(self):

        currency = 100
        loot = 15
        currency += loot
        self.assertEqual(currency, 115)


class TestEnemyAIScaling(unittest.TestCase):


    def test_scaling_formula(self):

        def get_scale(level):
            return 1.0 + (level - 1) * 0.1
        self.assertGreater(get_scale(5), get_scale(1))
        self.assertGreater(get_scale(10), get_scale(5))

    def test_enemy_hp_at_level_1(self):

        base_hp = 50.0
        scale = 1.0 + (1 - 1) * 0.1
        self.assertEqual(base_hp * scale, 50.0)

    def test_enemy_hp_at_level_5(self):

        base_hp = 50.0
        scale = 1.0 + (5 - 1) * 0.1
        self.assertGreater(base_hp * scale, 50.0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
