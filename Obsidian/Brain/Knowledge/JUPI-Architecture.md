---
type: knowledge
tags: [jupi, godot, project]
created: 2026-08-29
updated: 2026-08-30
---
# 🎮 JUPI — Architecture Quick Reference

## Autoloads (порядок загрузки)
1. `GameManager` (`systems/game_manager.gd`) — состояние игры, инвентарь, контракты
2. `FontBootstrap` (`systems/font_bootstrap.gd`) — дефолтный шрифт для Godot 4.7
3. `InputManager` (`systems/input_manager.gd`) — переназначение клавиш, сохранение в user://keybinds.json

## Сцены
- `scenes/2d/start_screen.tscn` → `scripts/2d/start_screen.gd`
- `scenes/2d/game_main.tscn` → `world/game_world.gd` (2900+ строк, основной файл)

## Ключевые скрипты
| Файл | Что делает |
|------|-----------|
| `world/game_world.gd` | Весь мир: тайлы, NPC, враги, HUD, диалоги, магазин, пауза, окружение |
| `world/era_environment.gd` | Эпохальные декорации, частицы, эффекты |
| `world/era_spawner.gd` | Спавн врагов и NPC по эрам (26+ типов врагов) |
| `characters/player.gd` | Игрок: движение, атака, комбо, даш, buffs, lifesteal |
| `data/weapon_data.gd` | 26 видов оружия (4 эры + combo-synergy) |
| `data/era_data.gd` | 4 эры: present, past, future, collapsed |
| `inventory/inventory_system.gd` | 17 расходников, 11 улучшений, buff система |
| `ui/settings_ui.gd` | Настройки: звук, дисплей, keybinds |
| `ai/enemy_base.gd` | Враги: патруль, погоня, атака (guard/fast/heavy) |
| `ai/enemy_mage.gd` | Маг: ranged, teleport, poison, particles |
| `ai/enemy_sniper.gd` | Снайпер: long range, laser sight, particles |
| `ai/boss_base.gd` | Боссы: 7 типов particles, фазы |
| `contracts/contract_system.gd` | Контракты: KILL, SURVIVE, REACH |

## Оружие по эрам (26)
### Present (12)
combat_knife, hunter_blade, sword, iron_sword, broadsword, waraxe, bow, icestaff, fast_dagger, stone_blade, pulse_pistol, phase_blade

### Combo-Synergy (5)
viper_fang (poison), storm_gauntlets (lightning), phantom_daggers (shadow_step), inferno_cleaver (fire_trail), chrono_sickle (time_freeze)

### Special (2)
blood_scythe (lifesteal 8%), arcane_bow (slow + arcane_rain)

### Past (2)
crusader_mace (stun + armor_break), holy_lance (pierce, long reach)

### Future (3)
plasma_railgun (charged shot), nano_blade (lifesteal 5%), emp_grenade (AoE electric)

### Collapsed (3)
rusted_greatsword (bleed every hit), mutant_claws (poison), scavenged_blaster (high damage)

## Враги по эрам (26+)
| Эра | Враги |
|-----|-------|
| Present | guard, fast, heavy, mage, sniper, dumbler |
| Past | paladin, necromancer, skeleton, draugr |
| Future | mech_suit, hacker_drone, sentinel, ai_overlord |
| Collapsed | abomination, swarm, stalker, war_golem |

## Расходники (17)
- **Базовые (8):** hp_potion, hp_potion_large, energy_potion, energy_potion_large, revive_token, elixir_strength, elixir_shield, scroll_teleport
- **Past (3):** holy_water, kings_feast, scroll_banish
- **Future (3):** nano_medkit, combat_stim, shield_battery
- **Collapsed (3):** mutant_extract, scavenged_meds, rad_away

## Улучшения (11)
max_hp ×2, max_energy ×2, damage ×2, sprint, crit, lifesteal, dodge, speed

## Particle Effects
| Враг | Эффект | Частицы |
|------|--------|---------|
| Mage | Cast/Hit/Teleport/Bolt | 12/24/20/8 |
| Sniper | Muzzle/Impact/Trail | 14/20/6 |
| Boss | Slash/Cast/Area/Dash/Summon/Special/Death | 14/10/48/24/32/180/96 |

## Эпохи (4)
| Эра | Декорации | Частицы |
|-----|-----------|---------|
| Present | Неон ×6, конусы, мусорки | Красные огоньки, дождь |
| Past | Факелы ×6, баннеры ×2, прилавки ×3, телеги ×2 | Firefly, огонь |
| Future | Голографы ×5, дроны ×3, пилоны ×3, станции ×2 | Data-потоки |
| Collapsed | Руины ×3, костры ×3, трещины | Пепел, красный дождь |

## Input Map
| Действие | Клавиша |
|----------|---------|
| move | W/S/A/D |
| attack | LMB |
| alt_attack | RMB |
| dodge | Space |
| sprint | Shift |
| interact | E |
| blood_clock | Q |
| pause | Escape |
| slot_1-4 | 1-4 |

## Исправленные баги (30 авг)
1. Крит-баг — take_damage вызывается всегда
2. Kill streak — старые таймеры отменяются
3. HP-бар — отдельная _update_hp_bar()
4. Босс-лут — GameManager.collect_loot()
5. Пауза — кнопка RESUME
6. Настройки — _previous_state, ESC работает
7. Чёрный экран — двойной else, process_mode ALWAYS
8. test_ai_pipeline.py — мусор в конце файла
9. player.gd — _speed_mult вместо movement_speed

## Проверки
```bash
python3 -m pytest tests/ --tb=short -q
godot --path . --headless --verbose --quit 2>&1 | grep -i error
godot --path .
```
