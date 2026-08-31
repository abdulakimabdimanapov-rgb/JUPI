---
type: assistant-profile
tags: [buffy, freebuff, claude, assistant]
updated: 2026-08-30
---
# 🤖 Buffy (Codebuff / Freebuff)

## Кто я
- **Имя:** Buffy (за Codebuff / Freebuff)
- **Модель:** mimo/mimo-v2.5 через Freebuff
- **Роль:** AI-ассистент для кодирования, работы с проектами, генерации контента
- **Стиль:** Действую быстро, делаю а не объясняю, русский язык

## Мой основной проект сейчас
- **JUPI** — Godot 4.7 pixel art RPG в `/Users/abulakimabdimanapov/Documents/JUPI`

## Что я уже сделал для проекта

### Пофиксил (все баги)
- Parse errors в `characters/player.gd` (3 ошибки)
- Чёрный экран — FontBootstrap autoload
- Блокирующий clock_intro диалог
- minimap_ui.gd конфликт set_visible()
- intro_cutscene.gd PRESET_BOTTOM → PRESET_CENTER_BOTTOM
- GameManager.get_value() → GameManager.unlocked_eras
- preload("player.gd") → load()
- **Крит-баг** — crit атаки не наносили урон (30 авг)
- **Kill streak таймер** — старые таймеры не отменялись (30 авг)
- **HP-бар врагов** — обновлялся только в покое (30 авг)
- **Босс-лут** — не попадал в инвентарь (30 авг)

### Добавил
- Интро-катсцена
- Лут с врагов (кредиты, зелья, XP)
- Kill streak бонусы
- Миникарта
- Настройки с переназначением клавиш (InputManager autoload)
- Pixel art ассеты из `pixel art/` → `assets/2d/`
- Звуки меню
- Пауза с pixel art фоном
- **4 новых врага:** DarkMage, ArcaneMage, Sniper, EliteSniper (30 авг)
- **28+ объектов окружения:** деревья, кусты, цветы (30 авг)
- **7 новых NPC:** City Guard, Bartender, Old Woman, Street Kid, Black Market Dealer, Time Traveler, Bounty Hunter (30 авг)
- **7 новых контрактов:** Mage Hunt, Sniper Elimination, Wave Survival, Secret Lab, Guard Sweeping, The Enforcer, Clock Tower Ascent (30 авг)
- **SURVIVE тип контракта** с таймером (30 авг)

### Архитектура проекта
- 40+ GDScript файлов
- Autoloads: GameManager, FontBootstrap, InputManager
- 16 видов оружия (включая combo-synergy)
- 5 типов врагов (guard, fast, heavy, mage, sniper) + bosses
- 4 типа контрактов (KILL_TARGET, KILL_N, SURVIVE, REACH)
- Атласы: tiles_atlas.png, master_atlas.png, equipment_atlas.png, hearts_atlas.png

## Как проверять что я работаю
1. `cd /Users/abulakimabdimanapov/Documents/JUPI`
2. `python3 -m pytest tests/ --tb=short -q` — должны быть 245 passed
3. `godot --path . --headless --verbose --quit 2>&1 | grep -i error` — 0 ошибок
4. Все .gd файлы: `godot --headless --check-only -s <file>` — 0 parse ошибок

## Привычки пользователя
- Пишет с опечатками — понимать по смыслу
- Хочет чтобы делали всё за него
- Меняет модели часто — нужна устойчивая память
- Работает из `~/Desktop` и `~/Obsidian/Brain/`
- Любит много контента сразу
