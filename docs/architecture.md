# Technical Architecture: Big O: Technical Debt

This document provides a detailed overview of the software architecture, design patterns, and system interactions for the Godot 4 project "Big O: Technical Debt."

---

## 1. Core Architectural Principles

### 1.1 Composition over Inheritance (ECS Hybrid)
The project utilizes a component-based design for entities. This modular approach allows for flexible behavior assignment without the rigidity of deep inheritance.
- **Entities** (`Player`, `BaseEnemy`) act as containers.
- **Components** (`MovementComponent`, `VisualsComponent`, `EnemyHealthComponent`) handle specific logic domains.

### 1.2 Event-Driven Communication
To minimize tight coupling between disparate systems (e.g., Gameplay logic and UI), the project relies on a global **Event Bus** pattern:
- **`GameEvents` (Singleton):** Central hub for high-level game state signals (`ram_changed`, `player_died`, `complexity_tier_changed`).
- **Local Signals:** Used for internal component-to-parent communication (e.g., `health_depleted` in `EnemyHealthComponent` notifies `BaseEnemy`).

### 1.3 Resource-Based Configuration
Game balancing and data definitions are abstracted into `Resource` files (`.tres`):
- **`PlayerComplexity`:** Defines physics and visual properties for each Big O tier.
- **`EnemyConfig`:** Stores base stats (speed, damage, health) for different enemy types.
- **`CollectibleData`:** Configures weights and effects for packets.

---

## 2. Key Systems & Deep Dives

### 2.1 The Player System (`player.gd`)
The `Player` (a `CharacterBody2D`) is the central entity, coordinating several modular components:

#### **MovementComponent (`movement_component.gd`)**
- **Physics:** Implements "Agar.io-style" mouse drift.
- **Lag Simulation:** Uses a history buffer (`_input_history_pos` and `_input_history_time`) to delay movement based on the current tier's `input_lag`.
- **Optimization:** Utilizes `PackedFloat64Array` and `PackedVector2Array` to minimize garbage collection during the history cleanup loop.
- **External Forces:** Provides `apply_external_force()` for environmental effects like gravity wells or tethers.

#### **VisualsComponent (`visuals_component.gd`)**
- **Interpolation:** Uses `Tween` to smoothly transition scale, color, and animation states between tiers.
- **Feedback:** Manages visual-only effects like "Processing" flickers, "Disruption" glitches, and "Ghost" trails for the Zombie Fork.
- **Collision Management:** Dynamically updates the `CollisionShape2D` size and offset to match the player's visual complexity.

#### **SystemResourcesComponent (`system_resources_component.gd`)**
- **Resource Management:** Tracks "RAM" usage as a percentage (0-100%).
- **Thresholds:** Emits signals via `GameEvents` when RAM reaches "Critical" (70%) or "Overflow" (100%) states.

---

### 2.2 Complexity & Optimization Manager (`complexity_manager.gd`)
Attached to the Player, this manager handles the core "Reverse Growth" progression:
- **Refactor Loop:** `add_optimization_fragment()` increments the meter. When full, it emits `optimization_ready`, triggering the Player's **Processing** state.
- **Tier Transition:** Upon `complete_refactor()`, it updates the player's complexity tier (e.g., $O(2^n) \rightarrow O(n^2)$), fundamentally altering physics via the `PlayerComplexity` resource.
- **Technical Debt:** `accumulate_debt()` forces a tier downgrade, acting as a penalty for the "Zombie Fork" or taking damage.

---

### 2.3 Enemy & Difficulty System

#### **BaseEnemy (`base_enemy.gd`)**
- **Lightweight Architecture:** Extends `Area2D` to avoid the overhead of `CharacterBody2D` physics solvers.
- **Culling:** Automatically deletes itself using `_check_cull_distance()` if it drifts too far from the player (e.g., 2500px).
- **Simplified AI:** Implements `_process_simplified_behavior()` to reduce CPU load when off-screen.

#### **EnemySpawner (`enemy_spawner.gd`)**
- **Radial Spawning:** Calculates random spawn positions in a ring around the player (`spawn_distance_min` to `spawn_distance_max`).
- **Wave Progression:** Implements a three-tier difficulty system:
    - **Tier 1:** Introductory enemies (`NullPointer`, `MemoryLeak`).
    - **Tier 2:** Intermediate threats (`StackOverflow`, `SpaghettiCode`).
    - **Tier 3:** Maximum complexity (`InfiniteLoop`, `Heisenberg`).
- **Intelligent Mixing:** Tracks `_last_spawned_types` to prevent excessive clustering of the same enemy type.

---

### 2.4 Collectible Pooling & World Management (`collectible_manager.gd`)
- **Object Pooling:** Maintains a pre-allocated pool of `base_collectible.tscn` instances to prevent frame stutters from instantiation during gameplay.
- **Sector-Based Spawning:**
    - Divides the infinite map into "Sectors" (chunks).
    - As the player moves, sectors are generated using coordinates as seeds for deterministic spawning.
    - Distant sectors are unloaded, and their collectibles are returned to the pool.

---

## 3. Communication & Data Flow

### 3.1 Global Event Bus (`GameEvents.gd`)
The primary decoupled communication channel.
- **Source:** Entities (Player, Enemies) and Managers (Spawner, CollectiblePool).
- **Target:** UI (HUD, Game Over), Screen FX, and World Logic.

### 3.2 Interaction Flow: Taking Damage
1. **Collision:** `BaseEnemy._on_body_entered()` detects `Player`.
2. **Signal:** Enemy calls `Player.take_damage()` and `Player.add_ram()`.
3. **Logic:** 
    - `SystemResourcesComponent` updates RAM and emits `GameEvents.ram_changed`.
    - `ComplexityManager` calls `accumulate_debt()`, downgrading the tier.
4. **Visuals:** `VisualsComponent` plays an error effect; `HUD` updates RAM bar and complexity label via `GameEvents`.

---

## 4. Performance Optimizations

- **Zero-Allocation Physics:** `MovementComponent` uses pre-allocated `PackedArrays` for input history.
- **No move_and_slide():** Enemies use direct `position` updates to bypass the heavy Godot physics solver.
- **Signal-Only UI:** UI elements do not use `_process()`. They only redraw when receiving signals from `GameEvents`.
- **Determinisitc Chunks:** Sector generation uses coordinate-based seeding to ensure the "infinite" world feels consistent without storing map data.

---

## 5. Directory Architecture
- `scripts/components/`: Modular entity logic.
- `scripts/managers/`: Global orchestration systems.
- `scripts/player/player_states/`: (Optional) Node-based state implementations.
- `resources/`: Data-driven configurations.
- `shaders/`: Screen-space and object-based visual effects.
