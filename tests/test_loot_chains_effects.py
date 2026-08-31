

import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)



class TestLootTable:


    def _load(self):
        path = os.path.join(ROOT, "data", "loot_table.gd")
        with open(path) as f:
            return f.read()

    def test_exists(self):
        assert os.path.exists(os.path.join(ROOT, "data", "loot_table.gd"))

    def test_has_class_name(self):
        c = self._load()
        assert "class_name LootTable" in c

    def test_loot_items_defined(self):
        c = self._load()
        assert "LOOT_ITEMS" in c
        assert "health_small" in c
        assert "energy_small" in c
        assert "credits_low" in c
        assert "ammo_pack" in c

    def test_all_rarities_present(self):
        c = self._load()
        assert '"rarity": "common"' in c or '"rarity":"common"' in c
        assert '"rarity": "uncommon"' in c or '"rarity":"uncommon"' in c
        assert '"rarity": "rare"' in c or '"rarity":"rare"' in c
        assert '"rarity": "epic"' in c or '"rarity":"epic"' in c
        assert '"rarity": "legendary"' in c or '"rarity":"legendary"' in c

    def test_rarity_weights(self):
        c = self._load()
        assert "RARITY_WEIGHTS" in c
        assert '"common"' in c
        assert '"uncommon"' in c
        assert '"rare"' in c
        assert '"epic"' in c
        assert '"legendary"' in c

    def test_rarity_colors(self):
        c = self._load()
        assert "RARITY_COLORS" in c

    def test_boss_loot_tables(self):
        c = self._load()
        assert "BOSS_LOOT" in c
        assert "corporate_enforcer" in c
        assert "warlord" in c
        assert "cyber_guardian" in c
        assert "time_devourer" in c

    def test_boss_guaranteed_drops(self):
        c = self._load()
        assert '"guaranteed"' in c
        assert "enforcer_badge" in c
        assert "ancient_blade" in c
        assert "pulse_core" in c
        assert "chrono_shard_legendary" in c

    def test_enemy_loot_tables(self):
        c = self._load()
        assert "ENEMY_LOOT" in c
        assert '"guard"' in c
        assert '"fast"' in c
        assert '"heavy"' in c
        assert '"drone"' in c
        assert '"android"' in c
        assert '"mutant"' in c

    def test_object_loot_tables(self):
        c = self._load()
        assert "OBJECT_LOOT" in c
        assert '"crate"' in c
        assert '"barrel"' in c
        assert '"dumpster"' in c
        assert '"chest"' in c

    def test_roll_boss_loot_function(self):
        c = self._load()
        assert "static func roll_boss_loot(" in c

    def test_roll_enemy_loot_function(self):
        c = self._load()
        assert "static func roll_enemy_loot(" in c

    def test_roll_object_loot_function(self):
        c = self._load()
        assert "static func roll_object_loot(" in c

    def test_apply_loot_function(self):
        c = self._load()
        assert "static func apply_loot(" in c

    def test_get_item_function(self):
        c = self._load()
        assert "static func get_item(" in c

    def test_get_rarity_color_function(self):
        c = self._load()
        assert "static func get_rarity_color(" in c

    def test_get_items_by_rarity_function(self):
        c = self._load()
        assert "static func get_items_by_rarity(" in c

    def test_get_all_item_ids_function(self):
        c = self._load()
        assert "static func get_all_item_ids(" in c

    def test_at_least_15_loot_items(self):
        c = self._load()
        items = ["health_small", "health_medium", "health_large", "health_full",
                  "energy_small", "energy_medium", "energy_large",
                  "credits_low", "credits_medium", "credits_high", "chrono_crystal",
                  "ammo_pack", "chrono_shard", "temporal_key",
                  "damage_booster", "speed_booster", "shield_module", "crit_enhancer",
                  "temporal_surge", "enforcer_badge", "ancient_blade", "pulse_core"]
        found = sum(1 for i in items if i in c)
        assert found >= 15

    def test_consumable_types(self):
        c = self._load()
        assert '"type": "consumable"' in c or '"type":"consumable"' in c

    def test_currency_types(self):
        c = self._load()
        assert '"type": "currency"' in c or '"type":"currency"' in c

    def test_buff_types(self):
        c = self._load()
        assert '"type": "buff"' in c or '"type":"buff"' in c

    def test_unique_types(self):
        c = self._load()
        assert '"type": "unique"' in c or '"type":"unique"' in c

    def test_icon_colors_defined(self):
        c = self._load()
        assert '"icon_color"' in c or '"icon_color":' in c

    def test_apply_loot_handles_all_types(self):
        c = self._load()
        assert '"consumable"' in c
        assert '"currency"' in c
        assert '"quest_item"' in c
        assert '"buff"' in c
        assert '"unique"' in c



class TestContractChains:


    def _load(self):
        path = os.path.join(ROOT, "data", "contract_chains.gd")
        with open(path) as f:
            return f.read()

    def test_exists(self):
        assert os.path.exists(os.path.join(ROOT, "data", "contract_chains.gd"))

    def test_has_class_name(self):
        c = self._load()
        assert "class_name ContractChains" in c

    def test_chains_defined(self):
        c = self._load()
        assert "CHAINS" in c

    def test_past_chains(self):
        c = self._load()
        assert "village_salvation" in c
        assert "ancient_knowledge" in c

    def test_present_chains(self):
        c = self._load()
        assert "corporate_conspiracy" in c
        assert "street_sweeper" in c

    def test_future_chains(self):
        c = self._load()
        assert "technology_preservation" in c
        assert "android_liberation" in c

    def test_collapsed_chains(self):
        c = self._load()
        assert "timeline_restoration" in c
        assert "scavenger_hunt" in c

    def test_chain_steps(self):
        c = self._load()
        assert '"steps"' in c
        assert '"step": 0' in c
        assert '"step": 1' in c
        assert '"step": 2' in c

    def test_chain_consequences(self):
        c = self._load()
        assert '"consequences"' in c

    def test_chain_final_flags(self):
        c = self._load()
        assert '"final_flag"' in c
        assert "past_village_saved" in c
        assert "corporate_conspiracy_exposed" in c
        assert "technology_preserved" in c
        assert "timeline_restored" in c

    def test_chain_unlocks(self):
        c = self._load()
        assert '"unlocks"' in c

    def test_chain_difficulty(self):
        c = self._load()
        assert '"difficulty"' in c

    def test_dynamic_templates(self):
        c = self._load()
        assert "DYNAMIC_TEMPLATES" in c
        assert "kill_progressive" in c
        def test_chain_objectives(self):
            c = self._load()
            assert '"objectives"' in c

    def test_api_functions(self):
        c = self._load()
        assert "static func get_chains_for_era(" in c
        assert "static func get_available_chains(" in c
        assert "static func start_chain(" in c
        assert "static func advance_chain(" in c
        assert "static func get_chain_progress(" in c
        assert "static func generate_dynamic_chain(" in c
        assert "static func get_chain(" in c

    def test_at_least_6_chains(self):
        c = self._load()
        chains = ["village_salvation", "ancient_knowledge", "corporate_conspiracy",
                   "street_sweeper", "technology_preservation", "android_liberation",
                   "timeline_restoration", "scavenger_hunt"]
        found = sum(1 for ch in chains if ch in c)
        assert found >= 6

    def test_chain_has_timeout(self):
        c = self._load()
        assert '"timeout"' in c

    def test_chain_has_kill_target(self):
        c = self._load()
        assert '"kill_target"' in c



class TestEffectsManager:


    def _load(self):
        path = os.path.join(ROOT, "world", "effects_manager.gd")
        with open(path) as f:
            return f.read()

    def test_exists(self):
        assert os.path.exists(os.path.join(ROOT, "world", "effects_manager.gd"))

    def test_has_class_name(self):
        c = self._load()
        assert "class_name EffectsManager" in c

    def test_combat_effects(self):
        c = self._load()
        assert "spawn_hit_effect" in c
        assert "spawn_crit_effect" in c
        assert "spawn_knockback_effect" in c
        assert "spawn_death_effect" in c

    def test_loot_effects(self):
        c = self._load()
        assert "spawn_loot_effect" in c

    def test_xp_effects(self):
        c = self._load()
        assert "spawn_xp_orb" in c
        assert "spawn_level_up_effect" in c

    def test_time_travel_effects(self):
        c = self._load()
        assert "spawn_time_travel_effect" in c
        assert "spawn_paradox_effect" in c
        assert "spawn_era_arrival_effect" in c

    def test_discovery_effects(self):
        c = self._load()
        assert "spawn_secret_discovery_effect" in c
        assert "spawn_location_discovered_effect" in c

    def test_ambient_effects(self):
        c = self._load()
        assert "spawn_temporal_flicker" in c
        assert "spawn_neon_surge" in c

    def test_screen_effects(self):
        c = self._load()
        assert "flash_screen" in c
        assert "screen_shake" in c

    def test_management(self):
        c = self._load()
        assert "func update(" in c
        assert "func clear_all(" in c
        assert "func get_active_count(" in c

    def test_setup(self):
        c = self._load()
        assert "func setup(" in c

    def test_active_effects_tracking(self):
        c = self._load()
        assert "_active_effects" in c
        assert "_register_effect" in c



class TestLootIntegration:


    def _load_gm(self):
        path = os.path.join(ROOT, "systems", "game_manager.gd")
        with open(path) as f:
            return f.read()

    def test_collect_loot_method(self):
        c = self._load_gm()
        assert "func collect_loot(" in c

    def test_loot_history_tracking(self):
        c = self._load_gm()
        assert "loot_history" in c
        assert "total_loot_collected" in c

    def test_buy_item_method(self):
        c = self._load_gm()
        assert "func buy_item(" in c

    def test_spend_currency_method(self):
        c = self._load_gm()
        assert "func spend_currency(" in c

    def test_add_currency_method(self):
        c = self._load_gm()
        assert "func add_currency(" in c

    def test_add_xp_method(self):
        c = self._load_gm()
        assert "func add_xp(" in c



class TestChainIntegration:


    def _load_gm(self):
        path = os.path.join(ROOT, "systems", "game_manager.gd")
        with open(path) as f:
            return f.read()

    def test_start_new_contract(self):
        c = self._load_gm()
        assert "func start_new_contract(" in c

    def test_complete_contract(self):
        c = self._load_gm()
        assert "func complete_contract(" in c

    def test_fail_contract(self):
        c = self._load_gm()
        assert "func fail_contract(" in c

    def test_active_contract(self):
        c = self._load_gm()
        assert "active_contract" in c

    def test_completed_contracts(self):
        c = self._load_gm()
        assert "completed_contracts" in c

    def test_contract_history(self):
        c = self._load_gm()
        assert "contract_history" in c



class TestEffectsWorldIntegration:


    def _load_gw(self):
        path = os.path.join(ROOT, "world", "game_world.gd")
        with open(path) as f:
            return f.read()

    def test_floating_text(self):
        c = self._load_gw()
        assert "_show_floating_text" in c

    def test_screen_flash_on_hit(self):
        c = self._load_gw()
        assert "flash" in c or "flash_screen" in c

    def test_death_effect(self):
        c = self._load_gw()
        assert "DeathOverlay" in c or "death_layer" in c



def run_tests():
    test_classes = [
        TestLootTable,
        TestContractChains,
        TestEffectsManager,
        TestLootIntegration,
        TestChainIntegration,
        TestEffectsWorldIntegration,
    ]

    total = 0
    passed = 0
    failed = 0
    errors = []

    for cls in test_classes:
        instance = cls()
        methods = [m for m in dir(instance) if m.startswith("test_")]
        for method_name in methods:
            total += 1
            method = getattr(instance, method_name)
            try:
                method()
                passed += 1
                print(f"  ✅ {cls.__name__}.{method_name}")
            except AssertionError as e:
                failed += 1
                errors.append(f"{cls.__name__}.{method_name}: {e}")
                print(f"  ❌ {cls.__name__}.{method_name}: {e}")
            except Exception as e:
                failed += 1
                errors.append(f"{cls.__name__}.{method_name}: {type(e).__name__}: {e}")
                print(f"  ❌ {cls.__name__}.{method_name}: {type(e).__name__}: {e}")

    print(f"\n{'='*60}")
    print(f"RESULTS: {passed}/{total} passed, {failed} failed")
    if errors:
        print(f"\nFailed tests:")
        for err in errors:
            print(f"  - {err}")
    print(f"{'='*60}")
    return failed == 0


if __name__ == "__main__":
    success = run_tests()
    sys.exit(0 if success else 1)
