---
type: projects
tags: [projects]
updated: 2026-08-30
---
# 🗂 Проекты пользователя

## 1. JUPI — Time Hunter (Godot 4.7 pixel art action RPG)
- **Путь:** `/Users/abulakimabdimanapov/Documents/JUPI`
- **Что это:** 2D pixel art action RPG с time-travel механикой, контрактами, комбо-оружием, магазином, NPC, эрами
- **Стек:** Godot 4.7 (GDScript), Python (тесты pytest 245+), pixel art спрайты
- **Статус:** Активная разработка — баги пофикшены, контент добавлен, эпохи работают
- **Ключевые файлы:**
  - `world/game_world.gd` — основной мир (2900+ строк)
  - `world/era_environment.gd` — эпохальные декорации и эффекты
  - `world/era_spawner.gd` — спавн врагов по эрам
  - `characters/player.gd` — игрок (1290+ строк)
  - `data/weapon_data.gd` — 26 видов оружия
  - `data/era_data.gd` — 4 эры (present, past, future, collapsed)
  - `inventory/inventory_system.gd` — 17 расходников, 11 улучшений
  - `ai/boss_base.gd` — боссы с 7 типами particles
  - `contracts/contract_system.gd` — контракты (KILL, SURVIVE, REACH)
- **Ассеты:** `pixel art/` — спрайты для тайлов, персонажей, UI; извлечены в `assets/2d/`
- **Sprite sheets:** `guard_sheet.png`, `fast_sheet.png`, `heavy_sheet.png`, `mage_sheet.png`, `sniper_sheet.png`, `boss_sheet.png` (128×64, 8×4 кадра)
- **Тесты:** `python3 -m pytest tests/ --tb=short -q` — 245/245
- **Запуск:** `godot --path .` или `godot --path . --headless --verbose --quit` для проверки
- **Что сделано 30 авг (финал):**
  - **Багфиксы (7):**
    - Крит-баг: crit атаки теперь наносят урон
    - Kill streak таймер: старые таймеры отменяются
    - HP-бар врагов: обновляется во всех состояниях
    - Босс-лут: попадает в инвентарь
    - Пауза: добавлена кнопка RESUME
    - Настройки: ESC работает, восстанавливает состояние
    - Чёрный экран: двойной else, process_mode ALWAYS
  - **Оружие (26):**
    - Present: 12 видов (combat_knife → phase_blade)
    - Past: Crusader Mace (stun), Holy Lance (pierce)
    - Future: Plasma Railgun, Nano Blade (lifesteal), EMP Grenade
    - Collapsed: Rusted Greatsword (bleed), Mutant Claws (poison), Scavenged Blaster
  - **Расходники (17):**
    - 8 базовых + 3 Past + 3 Future + 3 Collapsed
  - **Улучшения (11):**
    - HP, energy, damage, sprint, crit, lifesteal, dodge, speed
  - **Враги (26+):**
    - Present: guard, fast, heavy, mage, sniper, dumbler
    - Past: paladin, necromancer, skeleton, draugr
    - Future: mech_suit, hacker_drone, sentinel, ai_overlord
    - Collapsed: abomination, swarm, stalker, war_golem
  - **Анимации кадров** для mage, sniper, boss, dumbler из sprite sheets
  - **Particle эффекты:**
    - Mage: cast, hit, teleport, bolt trail
    - Sniper: muzzle, impact, bullet trail
    - Boss: melee slash, cast burst, area burst, dash trail, summon burst, special burst, death burst
  - **Эпохи (4):**
    - Present: неоновые вывески, конусы, мусорки
    - Past: факелы, баннеры, рыночные прилавки, телеги
    - Future: голографы, дроны, пилоны, зарядные станции
    - Collapsed: руины, костры, трещины, пепел
  - **NPC (7):** City Guard, Bartender, Old Woman, Street Kid, Black Market Dealer, Time Traveler, Bounty Hunter
  - **Контракты (7+):** Mage Hunt, Sniper Elimination, Wave Survival, Secret Lab, Guard Sweeping, The Enforcer, Clock Tower Ascent
  - **UI:** Иконка "JUPI" (из Sprite-0002.ase), спрайт ГГ (из Sprite-0001.ase)
  - **Тесты:** 245/245 ✅, 0 ошибок Godot ✅

## 2. FOL (Second Self) — AI-ассистент для macOS
- **Путь:** `~/Desktop/SecondSelf`
- **Что это:** персональный цифровой двойник / JARVIS
- **Статус:** v1.0-beta → v1.0.0, идёт переименование Second Self → FOL
- **Стек:** Python (orchestrator, FastAPI), SwiftUI, agent-server, Obsidian memory
- **Ключевое:** 989+ тестов; Obsidian Brain v5; эпизодическая память

## 3. TG-bot — Telegram-боты для грузоперевозок
- **Путь:** `~/Desktop/TG-bot`
- **Статус:** работает, есть тесты (pytest)

## 4. Прочее
- **IELTS** — подготовка к экзамену
- **Заработок онлайн** — ищет идеи

---

## 📋 История изменений
- 2026-08-30: JUPI — багфиксы (7), контент (оружие ×8, расходники ×9, враги ×12, декорации ×30), эпохи (present/past/future/collapsed), анимации, particles, иконка из .ase
- 2026-08-29: Добавлен проект JUPI. Пофиксены parse errors, чёрный экран. Добавлено переназначение клавиш.
