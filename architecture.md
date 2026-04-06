# Big O: Technical Debt - Architecture

## Overview

Godot 4.6 top-down reverse-growth arcade game where the player optimizes from $O(2^n)$ to $O(1)$ by collecting refactor packets while avoiding "Technical Debt" enemies.

## Core Systems

### Event Bus (GameEvents Autoload)

All systems communicate via signals in `scripts/globals/game_events.gd`. Components never poll; always connect to signals. Callbacks are prefixed with `_on_`.

```gdscript
# Example signal usage
GameEvents.ram_changed.emit(current, maximum)
GameEvents.complexity_tier_changed.emit(new_tier)
```

### Component-Based Player

Player uses composition via exported nodes:
- `MovementComponent` - Handles physics, input, and movement
- `VisualsComponent` - Handles sprite, animations, and visual effects
- `ComplexityManager` - Manages Big O tier state
- `SystemResourcesComponent` - Manages RAM resource

### Enemy System

All enemies extend `BaseEnemy` (`scripts/enemies/base_enemy.gd`):
- Lightweight `Area2D` entities (not `CharacterBody2D`)
- Direct `position += velocity * delta` movement
- Lifetime-based despawning (20-40s)
- Screen exit culling

Enemy types:
| Enemy | Behavior |
|-------|----------|
| Null Pointer | Fast, locks direction toward player |
| Memory Leak | Grows over time, continuous RAM drain |
| Infinite Loop | Orbits arena, gravitational pull |
| Heisenberg | Stalks player, disrupts controls |
| Spaghetti Code | Shoots tether cables |
| Stack Overflow | Approaches, crushes, retreats, grows |

### Difficulty Scaling

LOC-based intensity phases:
- **Alpha** (0-1000 LOC): 3.5s spawn delay, 15 max enemies
- **Beta** (1000-2000 LOC): 2.0s spawn delay, 30 max enemies  
- **Production** (2000+ LOC): 0.8s spawn delay, 50 max enemies

### Player State Machine

States in `scripts/player/player_states/`:
- `IDLE` - Normal movement
- `PROCESSING` - Refactoring in progress
- `DISRUPTED` - Controls jammed
- `ERROR` - Recently hit
- `FORKING` - Zombie Fork ability active
- `DEAD` - Game over

## Directory Structure

```
scripts/
├── core/              # World, main screen logic
├── enemies/           # Base enemy + specific enemies
├── player/           # Player, sub-thread, states
│   └── player_states/
├── components/       # Reusable components
├── managers/         # Game managers
├── globals/          # Autoloads (GameEvents, constants)
├── collectibles/     # Collectible logic
├── fx/               # Visual effects (screen shake, etc.)
└── ui/               # HUD, menus

scenes/
├── core/             # Main game scenes
├── enemies/          # Enemy scenes
├── player/           # Player scenes
├── ui/               # UI scenes
├── collectibles/     # Collectible scenes
└── environment/      # Backgrounds, effects
```

## Key Patterns

### Signal-Driven Architecture
1. Define signal in `GameEvents`
2. Emit from source: `GameEvents.some_signal.emit(args)`
3. Connect in consumer: `GameEvents.some_signal.connect(_on_handler)`

### Component Creation
1. Extend `Node`
2. Use `@export` for dependencies
3. Emit signals for state changes

### Enemy Creation
1. Extend `BaseEnemy`
2. Override `_process_movement()` and `_process_behavior()`
3. Set `config` for stats

### Performance Optimization
- Zero-allocation physics via `PackedFloat64Array` / `PackedVector2Array`
- Lightweight `Area2D` enemies (no `move_and_slide()`)
- Object pooling for collectibles
- Sector-based background rendering

## Scene Hierarchy

```
World
├── Player
│   ├── Camera2D
│   ├── MovementComponent
│   ├── ComplexityManager
│   ├── VisualsComponent
│   └── SystemResourcesComponent
├── Enemies (container)
├── Projectiles (container)
├── EnemySpawner
├── ControlDisruptor
├── GameOver (BSOD screen)
├── HUD
│   ├── RAMMeter
│   ├── ComplexityMeter
│   └── DifficultyCounter
└── BackgroundManager
```

## Constants & Configuration

All game constants in `scripts/globals/constants.gd`:
- Physics layers/masks
- Player tier stats
- Enemy configurations
- Spawn parameters

## Dependencies

- **Godot**: 4.6+
- **No external libraries**
- **No external assets** (placeholder sprites used)
