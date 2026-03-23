# Enemy Spawning System Plan

## Overview
Refactor the enemy spawning system to support complexity-matched waves with randomized spawning patterns.

---

## Current State
- Enemies spawn from 8 fixed cardinal directions (N, NE, E, SE, S, SW, W, NW)
- All enemy types have equal spawn probability
- Fixed spawn delay between enemies
- Base wave size: 3 enemies, +3 per wave

---

## Goals

### 1. Randomized Radial Spawning
- Replace fixed 8-direction spawning with 360° random angle around player
- Add minimum spawn distance (e.g., 500px from player)
- Add maximum spawn distance (e.g., 900px from player)

### 2. Complexity-Matched Waves
Group enemies by Big-O complexity and unlock them progressively:

| Wave Range | Complexity | Enemies |
|------------|------------|---------|
| 1-3 | O(1), O(n) | null_pointer, memory_leak |
| 4-6 | O(n log n), O(n²) | stack_overflow, spaghetti_code |
| 7+ | O(2^n) | infinite_loop, heisenberg |

### 3. Progressive Spawning
- Increase wave size by 2-3 enemies per wave
- Decrease spawn delay slightly per wave (min cap: 0.5s)
- Cap maximum active enemies at 30 (existing)

### 4. Intelligent Enemy Mixing
- Track recently spawned enemy types
- Prevent spawning 3+ of the same enemy type consecutively
- Weight spawn probability based on current wave tier

### 5. Spawn Distance Variance
- Randomize distance between min (e.g., 400px) and max (e.g., 800px)
- Creates depth and prevents enemies stacking on top of each other

---

## Implementation Tasks

### Phase 1: Core Spawning Refactor
- [ ] Add `min_spawn_distance` and `max_spawn_distance` export vars
- [ ] Replace `_get_spawn_position()` with randomized radial calculation
- [ ] Use `Vector2.from_angle(randf() * TAU)` for random direction

### Phase 2: Wave Tier System
- [ ] Create enemy tier definitions (tier 1, 2, 3)
- [ ] Add `current_tier` property to EnemySpawner
- [ ] Calculate tier based on `_current_wave`
- [ ] Filter `enemy_scenes` by tier when selecting spawn

### Phase 3: Progressive Difficulty
- [ ] Add `wave_size_increment` export var
- [ ] Add `spawn_delay_decrement` export var
- [ ] Implement spawn rate increase in `start_wave()`
- [ ] Add minimum spawn delay clamp

### Phase 4: Intelligent Mixing
- [ ] Add `_last_spawned_types` Array to track recent enemies
- [ ] Implement weighted random selection avoiding same-type clustering
- [ ] Add `_max_consecutive_same_type` constant (e.g., 2)

### Phase 5: Distance Variance
- [ ] Add `spawn_distance_min` and `spawn_distance_max` export vars
- [ ] Calculate distance randomly within range per spawn

---

## Enemy Complexity Reference

| Enemy | Complexity | Suggested Tier |
|-------|-------------|-----------------|
| null_pointer | O(1) | 1 |
| memory_leak | O(n) | 1 |
| spaghetti_code | O(n²) | 2 |
| stack_overflow | O(n) | 2 |
| infinite_loop | O(∞) | 3 |
| heisenberg | O(2^n) | 3 |

---

## Configuration Example

```gdscript
@export_category("Spawning")
@export var min_spawn_distance: float = 400.0
@export var max_spawn_distance: float = 800.0

@export_category("Wave Progression")
@export var wave_size_increment: int = 2
@export var spawn_delay_decrement: float = 0.1
@export var min_spawn_delay: float = 0.5
@export var max_consecutive_same_type: int = 2

@export_category("Tier Configuration")
@export var tier_1_waves: int = 3  # Waves 1-3: O(1), O(n)
@export var tier_2_waves: int = 6  # Waves 4-6: O(n²), O(n log n)
# Tier 3 starts at wave 7+
```

---

## Testing Checklist
- [ ] Enemies spawn at random angles (not fixed 8 directions)
- [ ] Early waves only spawn tier 1 enemies
- [ ] Mid waves include tier 1 + tier 2 enemies
- [ ] Late waves include all tiers
- [ ] No more than 2-3 of the same enemy type spawn consecutively
- [ ] Spawn distance varies between min and max values
- [ ] Wave size increases each wave
- [ ] Spawn delay decreases each wave (capped at minimum)
- [ ] Maximum active enemies still enforced (30)