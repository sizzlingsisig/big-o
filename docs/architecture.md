# Technical Architecture: Big O: Technical Debt

This document outlines the software architecture, design patterns, and system interactions for the Godot 4 project "Big O: Technical Debt."

---

## 1. Core Architectural Principles

### 1.1 Composition over Inheritance (ECS Hybrid)
The project follows a component-based design for major entities (Player, Enemies). Instead of deep inheritance hierarchies, functionality is encapsulated in specialized `Node` or `Node2D` components.

### 1.2 Event-Driven Communication
To minimize tight coupling, the system relies on a global **Event Bus** (`GameEvents`) and local **Signals**. This allows UI and managers to respond to game state changes without direct references to the source entities.

### 1.3 Resource-Based Configuration
Game balancing (Complexity Tiers, Enemy Stats) is handled via `Resource` files (`.tres`), allowing for rapid iteration without code changes.

---

## 2. Key Systems

### 2.1 Player System
The player is a `CharacterBody2D` that acts as a container for logic components:
- **Player Script (`player.gd`):** Manages high-level states (Idle, Processing, Disrupted, etc.) and orchestrates component interactions.
- **MovementComponent:** Implements mouse-drift physics with simulated input lag and inertia. Uses `PackedArray` for history tracking to maintain high performance.
- **VisualsComponent:** Handles sprite animations, smooth transitions between complexity tiers, and state-based visual effects (e.g., disruption glitching).
- **SystemResourcesComponent:** Manages the "RAM" (Health) resource, emitting signals for critical thresholds and overflows.

### 2.2 Complexity & Optimization
- **ComplexityManager:** A singleton-like manager (attached to the Player) that tracks the current Big O tier and optimization progress.
- **PlayerComplexity Resource:** Data containers defining speed, inertia, input lag, and visual scale for each tier.
- **Refactor Loop:** Collecting "Clean Code Packets" fills a meter; when full, the `ComplexityManager` triggers a "Processing" state in the Player before upgrading the tier.

### 2.3 Enemy & Technical Debt System
- **BaseEnemy (`base_enemy.gd`):** A lightweight `Area2D` base class for all enemies.
- **EnemySpawner:** Manages radial randomized spawning around the player. It implements a wave-based progression system that scales in complexity and density.
- **Movement Logic:** Enemies use direct position updates rather than `move_and_slide()` to minimize physics overhead.

### 2.4 Collectible & Pooling System
- **CollectiblePoolManager:** Implements an **Object Pool** to manage hundreds of collectibles without garbage collection stutters.
- **Chunk-Based Spawning:** The world is divided into sectors. The manager spawns and unloads collectibles based on the player's current sector and distance.

---

## 3. Data Flow & Communication

### 3.1 Global Event Bus (`GameEvents.gd`)
A central singleton that facilitates decoupled communication. Key events include:
- `ram_changed(current, max)`
- `complexity_tier_changed(new_tier)`
- `player_state_changed(new_state, old_state)`
- `sector_changed(coords)`

### 3.2 UI Integration
The `HUD` and `GameOver` screens connect to `GameEvents` in their `_ready()` functions. They update their display values only when events are received, avoiding expensive per-frame polling.

---

## 4. Performance Optimizations

- **Input History Buffering:** `MovementComponent` uses `Time.get_ticks_msec()` and `PackedVector2Array` to calculate lag-delayed positions with minimal memory allocation.
- **Lightweight Physics:** Enemies use `Area2D` instead of `CharacterBody2D`, avoiding collision solver overhead for non-essential entities.
- **Shaders vs. Sprites:** Heavy visual effects (Deep-Fry, BSOD Glitch) are implemented as screen-space shaders to offload work to the GPU.

---

## 5. Directory Structure
- `assets/`: Raw assets (sprites, sounds, fonts).
- `resources/`: ScriptableObject-style data files (Tiers, Enemy Configs).
- `scenes/`: Prefab-style scene files.
- `scripts/`:
    - `components/`: Modular logic for entities.
    - `managers/`: Global systems (Complexity, Spawning, Pooling).
    - `player/`: Player-specific scripts and states.
    - `globals/`: Singletons and constants.
- `shaders/`: GLSL shader code.
