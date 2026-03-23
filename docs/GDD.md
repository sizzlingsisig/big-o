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
A survival health bar tracking system instability. 
* **Increase:** RAM increases when enemies hit you or when you consume "Corrupted GC" packets.
* **Decrease:** Using the **Zombie Fork** ability (Spacebar) clears 20% RAM immediately. Some collectibles also drain RAM over time.

**Critical Threshold:** 70% - triggers warning state and visual glitches  
**Game Over:** 100% - triggers BSOD (Blue Screen of Death) crash screen

### Technical Debt (Enemies)
Enemies deal **RAM Damage** (instability) and **Contact Damage** (immediate Tier Downgrade). They are destroyed on player contact.

| Enemy | RAM / Tier Damage | Behavior |
|-------|-----------|---------|
| **Null Pointer** | 10% / 1 Tier | Fast-moving. Locks direction on spawn, then moves in a straight line. |
| **Memory Leak** | 12% / 1 Tier | Continuous RAM drain (1.5%/sec) while overlapping. |
| **Infinite Loop** | 15% / 1 Tier | Creates a gravitational pull dragging the player toward it. |
| **Heisenberg** | 18% / 1 Tier | Periodically disrupts player controls for 2 seconds. |
| **Spaghetti Code** | 15% / 1 Tier | Shoots tether cables that drag the player. |
| **Stack Overflow** | 20% / 1 Tier | Approaches, crushes (brief pause), then retreats. |

### Player Feedback
When hit by an enemy:
1. Player sprite flashes **red**
2. "ERROR" label appears above player
3. Debug console logs: `[ENEMY] X hit player! RAM +Y%`

### The "Zombie Fork"
*"Throw your child to death; his ghost lingers in your system, bloating your execution."*

**Mechanism:** Split off a ghostly child process that flies forward.
* **Benefit:** Instantly clears 20% RAM
* **Cost:** Forces player into a slower Big O tier (accumulated debt)
* **Cooldown:** 2 seconds

### Clean Code Packets (Collectibles)
The win condition is pure grind and survival. Collecting data fills a Complexity Meter on the HUD. When full, the player automatically drops one tier. The meter resets after each tier drop.

**Complexity Meter Scaling:**
| Current Tier | Commits Required |
|--------------|------------------|
| $O(2^n) \rightarrow O(n^2)$ | 2 |
| $O(n^2) \rightarrow O(n \log n)$ | 3 |
| $O(n \log n) \rightarrow O(n)$ | 4 |
| $O(n) \rightarrow O(\log n)$ | 5 |
| $O(\log n) \rightarrow O(1)$ | 6 |

*Why it scales:* Early tiers are miserable to play, so relief comes faster. The final stretch toward $O(1)$ is intentionally the hardest gate — those last 6 commits while fast and tiny should feel like a sprint against the clock.

### Collectible Items

| # | Name | Rarity | Sprite | Effect | Color |
|---|------|--------|--------|--------|-------|
| 1 | **Refactor Commit** | Common | 💾 Floppy disk | Fills Complexity Meter by 1 full commit (scaled per tier). | #00FF88 (mint green) |
| 2 | **Data Packet** | Abundant | 🟦 Tiny square | Fills Complexity Meter by a small fraction of a commit. | #00FFFF (cyan) |
| 3 | **Garbage Collector** | Common | 🗑️ Trash can | –15% RAM over 4s. | #AA00FF (purple) |
| 4 | **L1 Cache Hit** | Common | ⚡ Lightning bolt | Max speed + 0 inertia for 5s. | #0088FF (electric blue) |
| 5 | **Hotfix Patch** | Rare | 🩹 Bandage roll | RAM frozen for 8s. | #FFAA00 (orange) |
| 6 | **Corrupted GC** | Uncommon | 🗑️ Glitched trash | Mimics GC, flickers at 60–150px, drifts away on reveal, +20% RAM on pickup. | #FF0066 (hot pink) |
| 7 | **Code Freeze** | Rare | ❄️ Ice cube | Freezes all enemies in place for 4s. | #FFFFFF (white/ice) |

### Infinite World & Off-Screen Tracking
The game features an infinite scrolling continuous world. 
* **Dynamic Spawning:** Enemies and collectibles spawn relative to the player's position rather than a static map center.
* **Distance Culling:** Enemies leaving the screen enter a simplified AI state to save CPU, and are only deleted if they fall too far behind the player (`CULL_DISTANCE`).
* **Sector-Based Backgrounds:** The background dynamically shifts visual patterns based on the player's Euclidean distance from the origin.

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

For a deep dive into the system design, components, and data flow, see [Architecture.md](./architecture.md).

### Core Design
* **Component-Based Entities:** Entities like the Player and Enemies use modular components (`MovementComponent`, `VisualsComponent`, `SystemResourcesComponent`) to encapsulate logic.
* **Event-Driven UI:** The `HUD` and `GameOver` screens are decoupled from the game logic, updating via the `GameEvents` singleton.

### Performance Optimization
* **Zero-Allocation Physics:** `MovementComponent` uses `PackedFloat64Array` and `PackedVector2Array` to track input history, ensuring zero garbage allocation during the critical physics loop.
* **Lightweight Enemy System:** All enemies extend `BaseEnemy` which extends `Area2D` (not `CharacterBody2D`). Movement uses direct `position += velocity * delta`, avoiding the overhead of `move_and_slide()`.

### Event-Driven Architecture
* **Decoupled HUD:** `HUD` connects to managers in `_ready()` and only updates labels when signals (e.g., `ram_changed`, `sector_changed`) are received, avoiding per-frame polling.
* **Spawner Signals:** `EnemySpawner` emits signals for all enemy behaviors, which the `World` root connects to the player's status effect handlers.
* **Autoloads:** Heavy use of Singletons (`GameEvents`, `ScreenFX`, `CollectiblePool`) for global system coordination.

### Object Pooling & Memory Management
* **Collectible Pool:** To prevent Garbage Collection stutters in an infinite world, collectibles are managed by a `CollectiblePoolManager`. They are deactivated and recycled into a pool rather than being constantly instantiated and destroyed (`queue_free()`).

### Player State Machine
* The player controller uses a robust, decoupled State Machine pattern (`scripts/player/player_states/`) with distinct nodes for `Idle`, `Processing`, `Disrupted`, `Error`, `Forking`, and `Dead` states, ensuring clean logic separation.

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
* **Complexity Meter:** Horizontal bar tracking commits until the next tier drop. Flashes and resets on tier drop with a "compile complete" sound cue.
* **Wave Counter:** Current wave number

---

## Art Style

### Aesthetic
"Terminal Brainrot." A mix of high-end cyber-hacker visuals and distorted, low-quality meme energy.

### Visual Evolution
* $O(2^n)$ is red, shaky, and pixelated
* $O(1)$ is pure white, glowing, and high-definition

### References
* The clean grids of *Agar.io*
* The chaotic particle effects of *Vampire Survivors*
* The glitch-aesthetic of *Cyberpunk 2077*

### Sprite Sheet Specifications

#### Collectibles Sprite Sheet
**Layout:** 2 columns x 14 rows grid
* Column 1: Idle frame
* Column 2: Sparkle/active frame

| Row | Item | Glow Color |
|-----|------|------------|
| 1 | Refactor Commit | #00FF88 (mint green) |
| 2 | Data Packet | #00FFFF (cyan) |
| 3 | Garbage Collector | #AA00FF (purple) |
| 4 | L1 Cache Hit | #0088FF (electric blue) |
| 5 | Hotfix Patch | #FFAA00 (orange) |
| 6 | Corrupted GC | #FF0066 (hot pink) |
| 7 | Code Freeze | #FFFFFF (white) |

**Specs:**
- Cell size: 64x64px
- Cell spacing: 4px transparent gap
- Final size: 136x912px
- Background: WHITE (#FFFFFF)
- Style: Neon glow outlines (2px stroke), cyberpunk terminal aesthetic

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
| Milestone 4: System Refactor | ✅ Complete | Infinite world spawner, object pooling, player state machine, and modular enemies |
| Milestone 5: Polish | 🔄 In Progress | Sound design, collectible sprites, victory sequence at $O(1)$ |
| Milestone 6: Release | ⬜ Pending | Final testing and deployment |

**Platform:** Web (itch.io) / PC  
**Audience:** CS Students, Indie gamers, Memers (Ages 15–30)
