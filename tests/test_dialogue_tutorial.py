

import os
import sys
import json
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)



class TestDialogueData:


    def _load_class(self):
        path = os.path.join(ROOT, "data", "dialogue_data.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_dialogue_data_exists(self):
        assert os.path.exists(os.path.join(ROOT, "data", "dialogue_data.gd"))

    def test_dialogue_data_has_dialogues(self):
        content = self._load_class()
        assert "DIALOGUES" in content
        assert "informant_intro" in content

    def test_all_eras_have_dialogues(self):
        content = self._load_class()
        assert "informant_intro" in content
        assert "workshop_engineer" in content
        assert "past_merchant" in content
        assert "past_elder" in content
        assert "past_guard" in content
        assert "future_engineer" in content
        assert "future_scientist" in content
        assert "collapsed_survivor" in content
        assert "collapsed_scavenger" in content

    def test_boss_dialogues_exist(self):
        content = self._load_class()
        assert "boss_corporate" in content
        assert "boss_warlord" in content
        assert "boss_cyber" in content
        assert "boss_devourer" in content

    def test_npc_dialogue_mapping(self):
        content = self._load_class()
        assert "NPC_DIALOGUES" in content
        assert "Informant" in content
        assert "Engineer" in content
        assert "Pedestrian" in content

    def test_dialogue_nodes_have_text(self):
        content = self._load_class()
        assert '"text":' in content
        assert '"speaker":' in content

    def test_dialogue_choices_exist(self):
        content = self._load_class()
        assert '"choices":' in content
        assert '"next":' in content

    def test_dialogue_effects_exist(self):
        content = self._load_class()
        assert '"effects":' in content
        assert '"set_flag":' in content

    def test_dialogue_require_flag(self):
        content = self._load_class()
        assert '"require_flag":' in content

    def test_dialogue_has_start_nodes(self):
        content = self._load_class()
        assert '"start":' in content

    def test_dialogue_has_class_name(self):
        content = self._load_class()
        assert "class_name DialogueData" in content

    def test_dialogue_has_api_methods(self):
        content = self._load_class()
        assert "static func get_dialogue" in content
        assert "static func get_npc_dialogue" in content
        assert "static func get_dialogue_node" in content
        assert "static func get_start_node" in content
        assert "static func evaluate_conditions" in content
        assert "static func filter_choices" in content
        assert "static func apply_effects" in content
        assert "static func has_dialogue" in content

    def test_dialogue_filter_choices_function(self):
        content = self._load_class()
        assert "static func filter_choices(choices: Array, world_flags: Dictionary) -> Array:" in content

    def test_dialogue_evaluate_conditions_function(self):
        content = self._load_class()
        assert "static func evaluate_conditions(node: Dictionary, world_flags: Dictionary) -> bool:" in content



class TestDialogueUI:


    def _load_class(self):
        path = os.path.join(ROOT, "ui", "dialogue_ui.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_dialogue_ui_exists(self):
        assert os.path.exists(os.path.join(ROOT, "ui", "dialogue_ui.gd"))

    def test_dialogue_ui_signals(self):
        content = self._load_class()
        assert "signal dialogue_started" in content
        assert "signal dialogue_ended" in content
        assert "signal choice_made" in content

    def test_dialogue_ui_methods(self):
        content = self._load_class()
        assert "func open()" in content
        assert "func close()" in content
        assert "func start_dialogue(" in content
        assert "func start_npc_dialogue(" in content
        assert "func is_open()" in content

    def test_dialogue_ui_typewriter(self):
        content = self._load_class()
        assert "_typing" in content
        assert "_char_index" in content
        assert "_type_speed" in content

    def test_dialogue_ui_choices(self):
        content = self._load_class()
        assert "_choices_vbox" in content
        assert "Button.new()" in content

    def test_dialogue_ui_keyboard_input(self):
        content = self._load_class()
        assert "KEY_SPACE" in content
        assert "KEY_E" in content
        assert "KEY_ESCAPE" in content

    def test_dialogue_ui_extends_canvas_layer(self):
        content = self._load_class()
        assert "extends CanvasLayer" in content

    def test_dialogue_ui_layer(self):
        content = self._load_class()
        assert "layer = 45" in content



class TestTutorialManager:


    def _load_class(self):
        path = os.path.join(ROOT, "tutorial", "tutorial_manager.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_tutorial_manager_exists(self):
        assert os.path.exists(os.path.join(ROOT, "tutorial", "tutorial_manager.gd"))

    def test_tutorial_manager_has_class_name(self):
        content = self._load_class()
        assert "class_name TutorialManager" in content

    def test_tutorial_steps_enum(self):
        content = self._load_class()
        assert "enum Step" in content
        assert "MOVEMENT" in content
        assert "SPRINT" in content
        assert "ATTACK" in content
        assert "DODGE" in content
        assert "INTERACT" in content
        assert "BLOOD_CLOCK" in content
        assert "CONTRACT" in content
        assert "SHOP" in content
        assert "INVENTORY" in content
        assert "TIME_TRAVEL" in content
        assert "ERA_EXPLORATION" in content
        assert "BOSS_INTRO" in content
        assert "ADVANCED_COMBAT" in content
        assert "DIALOGUE" in content
        assert "PROGRESSION" in content

    def test_tutorial_step_data(self):
        content = self._load_class()
        assert "STEP_DATA" in content
        assert '"MOVEMENT":' in content or "Step.MOVEMENT" in content
        assert '"title":' in content
        assert '"text":' in content
        assert '"trigger":' in content

    def test_tutorial_step_order(self):
        content = self._load_class()
        assert "STEP_ORDER" in content
        assert "Step.MOVEMENT" in content
        assert "Step.ATTACK" in content

    def test_tutorial_methods(self):
        content = self._load_class()
        assert "func start()" in content
        assert "func stop()" in content
        assert "func is_active()" in content
        assert "func trigger(" in content
        assert "func get_current_step()" in content
        assert "func get_progress()" in content
        assert "func get_remaining_steps()" in content

    def test_tutorial_save_load(self):
        content = self._load_class()
        assert "func get_save_data()" in content
        assert "func load_save_data(" in content

    def test_tutorial_trigger_logic(self):
        content = self._load_class()
        assert "expected_trigger" in content
        assert "_complete_step" in content
        assert "_start_next_step" in content

    def test_tutorial_15_steps(self):
        content = self._load_class()
        step_count = content.count("Step.") // 2
        assert step_count >= 12



class TestTutorialUI:


    def _load_class(self):
        path = os.path.join(ROOT, "tutorial", "tutorial_ui.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_tutorial_ui_exists(self):
        assert os.path.exists(os.path.join(ROOT, "tutorial", "tutorial_ui.gd"))

    def test_tutorial_ui_signals(self):
        content = self._load_class()
        assert "signal tutorial_step_completed" in content
        assert "signal tutorial_completed" in content

    def test_tutorial_ui_methods(self):
        content = self._load_class()
        assert "func start_tutorial()" in content
        assert "func stop_tutorial()" in content
        assert "func is_active()" in content
        assert "func trigger(" in content

    def test_tutorial_ui_extends_canvas_layer(self):
        content = self._load_class()
        assert "extends CanvasLayer" in content

    def test_tutorial_ui_has_panel(self):
        content = self._load_class()
        assert "_panel" in content
        assert "_title_label" in content
        assert "_text_label" in content
        assert "_progress_label" in content

    def test_tutorial_ui_fade(self):
        content = self._load_class()
        assert "_fade_alpha" in content
        assert "_display_timer" in content

    def test_tutorial_ui_save_load(self):
        content = self._load_class()
        assert "func get_save_data()" in content
        assert "func load_save_data(" in content



class TestWorldContent:


    def _load_class(self):
        path = os.path.join(ROOT, "data", "world_content.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_world_content_exists(self):
        assert os.path.exists(os.path.join(ROOT, "data", "world_content.gd"))

    def test_world_content_has_class_name(self):
        content = self._load_class()
        assert "class_name WorldContent" in content

    def test_locations_defined(self):
        content = self._load_class()
        assert "LOCATIONS" in content
        assert "clock_tower" in content
        assert "hotel" in content
        assert "workshop" in content
        assert "bar" in content

    def test_locations_per_era(self):
        content = self._load_class()
        assert '"era": "present"' in content or '"era":"present"' in content
        assert '"era": "past"' in content or '"era":"past"' in content
        assert '"era": "future"' in content or '"era":"future"' in content
        assert '"era": "collapsed"' in content or '"era":"collapsed"' in content

    def test_secrets_defined(self):
        content = self._load_class()
        assert "SECRETS" in content
        assert "hidden_cache" in content
        assert "secret_passage" in content
        assert "past_altar" in content

    def test_collectibles_defined(self):
        content = self._load_class()
        assert "COLLECTIBLES" in content
        assert "health_potion" in content
        assert "energy_potion" in content
        assert "chrono_shard" in content

    def test_ambient_events_defined(self):
        content = self._load_class()
        assert "AMBIENT_EVENTS" in content
        assert "temporal_flicker" in content
        assert "ghostly_echo" in content

    def test_era_descriptions_defined(self):
        content = self._load_class()
        assert "ERA_DESCRIPTIONS" in content
        assert "present" in content
        assert "past" in content
        assert "future" in content
        assert "collapsed" in content

    def test_world_content_api(self):
        content = self._load_class()
        assert "static func get_location(" in content
        assert "static func get_locations_for_era(" in content
        assert "static func get_secret(" in content
        assert "static func get_secrets_for_era(" in content
        assert "static func get_collectible(" in content
        assert "static func get_ambient_events_for_era(" in content
        assert "static func get_era_description(" in content
        assert "static func check_ambient_event(" in content
        assert "static func find_nearest_secret(" in content
        assert "static func find_nearest_location(" in content

    def test_at_least_5_locations(self):
        content = self._load_class()
        locations = ["clock_tower", "hotel", "workshop", "bar", "apartments", "park",
                      "fortress", "village", "central_nexus", "ruins"]
        found = sum(1 for loc in locations if loc in content)
        assert found >= 5

    def test_at_least_3_secrets(self):
        content = self._load_class()
        secrets = ["hidden_cache_1", "hidden_cache_2", "secret_passage", "past_altar",
                    "future_terminal", "collapsed_bunker"]
        found = sum(1 for s in secrets if s in content)
        assert found >= 3

    def test_at_least_4_collectibles(self):
        content = self._load_class()
        items = ["health_potion", "energy_potion", "chrono_shard", "temporal_key",
                  "ancient_coin", "data_chip"]
        found = sum(1 for i in items if i in content)
        assert found >= 4

    def test_at_least_3_ambient_events(self):
        content = self._load_class()
        events = ["temporal_flicker", "ghostly_echo", "time_rift", "neon_surge", "ancient_wind"]
        found = sum(1 for e in events if e in content)
        assert found >= 3

    def test_4_era_descriptions(self):
        content = self._load_class()
        eras = ["present", "past", "future", "collapsed"]
        found = sum(1 for e in eras if e in content)
        assert found >= 4



class TestAmbientManager:


    def _load_class(self):
        path = os.path.join(ROOT, "world", "ambient_manager.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_ambient_manager_exists(self):
        assert os.path.exists(os.path.join(ROOT, "world", "ambient_manager.gd"))

    def test_ambient_manager_has_class_name(self):
        content = self._load_class()
        assert "class_name AmbientManager" in content

    def test_ambient_manager_signals(self):
        content = self._load_class()
        assert "signal secret_found" in content
        assert "signal collectible_collected" in content
        assert "signal ambient_event_triggered" in content
        assert "signal location_discovered" in content

    def test_ambient_manager_methods(self):
        content = self._load_class()
        assert "func setup(" in content
        assert "func update(" in content
        assert "func spawn_collectible(" in content
        assert "func get_found_secrets()" in content
        assert "func get_collected_items()" in content
        assert "func get_discovered_locations()" in content

    def test_ambient_manager_save_load(self):
        content = self._load_class()
        assert "func get_save_data()" in content
        assert "func load_save_data(" in content

    def test_ambient_manager_checks_secrets(self):
        content = self._load_class()
        assert "_check_secrets" in content
        assert "_check_collectibles" in content
        assert "_check_locations" in content
        assert "_check_ambient_events" in content

    def test_ambient_manager_collectible_texture(self):
        content = self._load_class()
        assert "_collectible_texture" in content
        assert "health_potion" in content
        assert "chrono_shard" in content



class TestGameManagerExtensions:


    def _load_class(self):
        path = os.path.join(ROOT, "systems", "game_manager.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_game_manager_has_dialogue_tracking(self):
        content = self._load_class()
        assert "npc_dialogue_history" in content
        assert "total_dialogues" in content

    def test_game_manager_dialogue_methods(self):
        content = self._load_class()
        assert "func record_dialogue(" in content
        assert "func has_talked_to(" in content
        assert "func get_npc_dialogue_state(" in content
        assert "func get_total_dialogues()" in content

    def test_game_manager_world_content_methods(self):
        content = self._load_class()
        assert "func get_world_description(" in content
        assert "func get_nearby_location(" in content
        assert "func get_nearby_secret(" in content

    def test_game_manager_tutorial_tracking(self):
        content = self._load_class()
        assert "tutorial_completed" in content

    def test_game_manager_save_version_4(self):
        content = self._load_class()
        assert '"version": 4' in content

    def test_game_manager_saves_dialogue_data(self):
        content = self._load_class()
        assert '"tutorial_completed"' in content
        assert '"dialogue_history"' in content
        assert '"total_dialogues"' in content



class TestGameWorldIntegration:


    def _load_class(self):
        path = os.path.join(ROOT, "world", "game_world.gd")
        with open(path) as f:
            content = f.read()
        return content

    def test_game_world_has_dialogue_ui(self):
        content = self._load_class()
        assert "_dialogue_ui" in content
        assert "DialogueUILoad" in content

    def test_game_world_has_tutorial_ui(self):
        content = self._load_class()
        assert "_tutorial_ui" in content
        assert "TutorialUILoad" in content

    def test_game_world_has_ambient_manager(self):
        content = self._load_class()
        assert "_ambient_manager" in content
        assert "AmbientManager.new()" in content

    def test_game_world_dialogue_integration(self):
        content = self._load_class()
        assert "start_dialogue_for_npc" in content

    def test_game_world_tutorial_triggers(self):
        content = self._load_class()
        assert "first_interact" in content
        assert "first_shop" in content
        assert "first_contract" in content
        assert "first_time_machine" in content
        assert "first_dialogue" in content

    def test_game_world_ambient_integration(self):
        content = self._load_class()
        assert "_ambient_manager.update" in content
        assert "_on_secret_found" in content
        assert "_on_location_discovered" in content

    def test_game_world_tutorial_start(self):
        content = self._load_class()
        assert "not GameManager.tutorial_completed" in content
        assert "_tutorial_ui.start_tutorial()" in content



def run_tests():

    test_classes = [
        TestDialogueData,
        TestDialogueUI,
        TestTutorialManager,
        TestTutorialUI,
        TestWorldContent,
        TestAmbientManager,
        TestGameManagerExtensions,
        TestGameWorldIntegration,
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
