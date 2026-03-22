# GDD: Big O: Technical Debt

## Game Identity / Mantra
A reverse-growth arcade "frenzy" where you play as a bloated, inefficient algorithm ($O(2^n)$) that must "eat" refactor packets to optimize into a god-like $O(1)$ state before Technical Debt crashes the CPU.

---

## Design Pillars
* **Entropy:** The mounting pressure of a system falling apart as RAM fills up.
* **Optimization:** The mechanical satisfaction of moving from "clunky" to "crisp."
* **Aura:** Over-the-top visual rewards for achieving maximum efficiency.

---

## Genre/Story/Mechanics Summary
**Genre:** Top-Down Reverse-Growth Arcade (Agar.io-inspired).  
**Story:** You are an **Execution Pulse** inside a corrupted operating system. You aren't growing bigger to win; you are shedding "bloat" to reach the Kernel.  
**Core Mechanic:** The player's **Complexity Tier** dictates physics. High complexity ($O(2^n)$) makes the player massive, slow, and laggy. Low complexity ($O(1)$) makes the player tiny and lightning-fast. You consume "Clean Code Packets" to lower your Big O tier, while avoiding various forms of "Technical Debt".

---

## Features

### Dynamic Complexity Tiers
The 6 tiers heavily modify movement physics, collision, and input responsiveness:

| Tier | Speed | Collider | Inertia | Input Lag |
|------|-------|----------|---------|-----------|
| $O(2^n)$ (Exponential) | 100 px/s | 96px | 0.9 | 0.3s |
| $O(n^2)$ (Polynomial) | 120 px/s | 80px | 0.7 | 0.2s |
| $O(n \log n)$ (Linearithmic) | 150 px/s | 70px | 0.5 | 0.1s |
| $O(n)$ (Linear) | 180 px/s | 65px | 0.3 | 0.05s |
| $O(\log n)$ (Logarithmic) | 200 px/s | 45px | 0.1 | 0.02s |
| $O(1)$ (Constant) | 220 px/s | 22px | 0.0 | 0.0s |

### RAM Gauge (Health)
A survival health bar. RAM **only increases** when enemies hit you. The only way to reduce RAM is to use the **Zombie Fork** ability (Spacebar), which clears 20% RAM.

**Critical Threshold:** 70% - triggers warning state  
**Game Over:** 100% - triggers BSOD crash screen

### Technical Debt (Enemies)
All enemies are lightweight `Area2D` entities with no physics overhead. They all destroy themselves on player contact.

| Enemy | RAM Damage | Behavior |
|-------|-----------|---------|
| **Null Pointer** | 10% | Fast-moving. Locks direction toward player on spawn, then moves in a straight line. |
| **Memory Leak** | 12% burst | Drifting blob that grows over time. Deals continuous RAM drain (1.5%/sec) while overlapping. |
| **Infinite Loop** | 15% | Orbits the arena. Creates a gravitational pull that drags the player toward it. |
| **Heisenberg** | 18% | Stalks the player slowly. Periodically disrupts player controls for 2 seconds. |
| **Spaghetti Code** | 15% | Slow-moving. Shoots tether cables that drag the player. |
| **Stack Overflow** | 20% | Approaches, crushes (brief pause), then retreats. Gets larger with each crush. |

### Player Feedback
When hit by an enemy:
1. Player sprite flashes **red**
2. "ERROR" label appears above player
3. Debug console logs: `[ENEMY] X hit player! RAM +Y%`

### The "Zombie Fork"*"Throw your child to death; his ghost lingers in your system, bloating your execution."*
**Mechanism:** Split off a ghostly child process that flies forward.
* **Benefit:** Instantly clears 20% RAM
* **Cost:** Forces player into a slower Big O tier (accumulated debt)
* **Cooldown:** 2 seconds

### Clean Code Packets (Collectibles)
* **Refactor Packet:** Core drop. Lowers tier by one step (e.g., $O(n^2) \rightarrow O(n \log n)$).
* **Big-O Shortcut:** Rare drop. Skips two tiers instantly.
* **Cache Hit:** Temp speed boost. Max velocity and zero inertia for 5 seconds.
* **Kernel Fragment:** End-game collectible. Collecting all 3 triggers the $O(1)$ transition.

### Visual Polish & Shaders
* **Brainrot Shaders:** Visual "Deep-Fry" filters, chromatic aberration, and screen shakes that intensify as the system nears a 100% RAM crash.
* **Complexity Aesthetics:** $O(2^n)$ is red, shaky, and pixelated; $O(1)$ is pure white, glowing, and high-definition.

### The $O(1)$ Singularity
Reaching the final tier triggers an automatic "Win Sequence" where the player's execution pulse expands to delete all Technical Debt from the screen, followed by a transition to the Kernel.

### Game Over Screen (BSOD)
When RAM reaches 100%, a Blue Screen of Death appears:
- Displays random crash codes (0x0000000D, 0xDEADBEEF, etc.)
- Shows RAM usage percentage and wave reached
- Visual glitch effect with screen shake
- Press **Space** to restart, **Escape** to quit

---

## Progression & Score

### Lines of Code (LOC)
Primary score metric representing the amount of data processed and optimized.
* **Alpha Phase (0-500 LOC):** Stable system, introductory enemies.
* **Beta Phase (500-1500 LOC):** Increased enemy density, subtle glitch effects.
* **Production (1500+ LOC):** Critical instability, aggressive technical debt, max glitch intensity.

---

## Technical Architecture

### Entity Component System (ECS) Hybrid
* Entities use dedicated components (`MovementComponent`, `VisualsComponent`, `ComplexityManager`) for modular logic.
* Decoupled communication via Signals (e.g., `thread_forked`, `player_gravity_pull`, `leaking_ram`).

### Performance Optimization
* **Zero-Allocation Physics:** `MovementComponent` uses `PackedFloat64Array` and `PackedVector2Array` to track input history, ensuring zero garbage allocation during the critical physics loop.
* **Lightweight Enemy System:** All enemies extend `BaseEnemy` which extends `Area2D` (not `CharacterBody2D`). Movement uses direct `position += velocity * delta`, avoiding the overhead of `move_and_slide()`.

### Event-Driven Architecture
* **Decoupled HUD:** `HUD` connects to managers in `_ready()` and only updates labels when signals (e.g., `ram_changed`, `sector_changed`) are received, avoiding per-frame polling.
* **Spawner Signals:** `EnemySpawner` emits signals for all enemy behaviors, which the `World` root connects to the player's status effect handlers.

### Scene Hierarchy
```
World
├── Player
├── Enemies (container)
├── Projectiles (container)
├── EnemySpawner
├── ControlDisruptor
├── GameOver (BSOD screen)
├── HUD
│   └── RAMMeter
└── WaveTimer
```

---

## Interface

### Input
* **Mouse Move:** Algorithm drifts toward cursor (Inertia and Input Lag depend on tier)
* **Spacebar:** Activate "Zombie Fork" (RAM dump + debt accumulation)
* **Debug (dev builds):** Up arrow = refactor, Down arrow = accumulate debt

### Controls Summary
| Input | Action |
|-------|--------|
| Mouse | Move player |
| Spacebar | Zombie Fork |
| Escape | Quit (on game over) |

### UI Elements
* **RAM Meter:** Vertical progress bar showing current RAM usage
* **Complexity Display:** Shows current Big O tier
* **Wave Counter:** Current wave number

---

## Art Style
**Aesthetic:** "Terminal Brainrot." A mix of high-end cyber-hacker visuals and distorted, low-quality meme energy.
* **References:** The clean grids of *Agar.io*, the chaotic particle effects of *Vampire Survivors*, and the glitch-aesthetic of *Cyberpunk 2077*.
* **Visual Evolution:** $O(2^n)$ is red, shaky, and pixelated; $O(1)$ is pure white, glowing, and high-definition.

---

## Wave System
| Parameter | Value | Description |
|-----------|-------|-------------|
| `base_wave_size` | 3 | Starting enemies per wave |
| `enemies_per_wave_increase` | 3 | Additional enemies each wave |
| `spawn_delay` | 1.5s | Time between enemy spawns |
| `time_between_waves` | 8.0s | Rest period between waves |

---

## Music / Sound
* **Dynamic Bitrate:** The background track is "bass-boosted" and muffled at high complexity, becoming clear and melodic as the player optimizes.
* **SFX:** 
  * "Vine Thud" on heavy collisions
  * Mechanical keyboard "clacks" for UI interaction
  * Windows XP-style error sounds when the RAM gauge is critical
* **Emotional Goal:** Transition from "Anxious Chaos" to "Calculated Power."

---

## Development Roadmap

| Milestone | Status | Description |
|-----------|--------|-------------|
| Milestone 1: Logic Core | ✅ Complete | Tier-switching system and scale-based movement logic |
| Milestone 2: Debt AI | ✅ Complete | All 6 enemy types with behaviors |
| Milestone 3: Visual Identity | ✅ Complete | RAM Gauge UI, game over screen, player hit feedback |
| Milestone 4: Polish | 🔄 In Progress | Sound design, victory sequence at $O(1)$ |
| Milestone 5: Release | ⬜ Pending | Final testing and deployment |

**Platform:** Web (itch.io) / PC  
**Audience:** CS Students, Indie gamers, Memers (Ages 15–30)
