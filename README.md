# Big O: Technical Debt

## Script Reference Conventions

- Use explicit preload aliases for utility scripts in runtime code to avoid language-server class index drift.
- Current utility alias pattern: `const SectorGridScript = preload("res://scripts/globals/sector_grid.gd")`.
- Prefer calling helpers through the alias (for example, `SectorGridScript.get_sector_at_position(...)`).

### Keep Direct Global References For

- `GameEvents` (autoload signal bus).
- `BigOConstants` (`class_name` constants holder).

### Example Files

- `scripts/collectibles/collectible_manager.gd`
- `scripts/managers/background_manager.gd`
- `scripts/ui/hud.gd`
