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
* **Dynamic Complexity Tiers:** The 6 tiers heavily modify movement physics, collision, and input responsiveness:
	* **$O(2^n)$ (Exponential):** 100px/s speed, 96px collider, 0.9 inertia, 0.3s input lag.
	* **$O(n^2)$ (Polynomial):** 120px/s speed, 78px collider, 0.7 inertia, 0.2s lag.
	* **$O(n \log n)$ (Linearithmic):** 140px/s speed, 60px collider, 0.5 inertia, 0.1s lag.
	* **$O(n)$ (Linear):** 160px/s speed, 48px collider, 0.3 inertia, 0.05s lag.
	* **$O(\log n)$ (Logarithmic):** 180px/s speed, 36px collider, 0.1 inertia, 0.02s lag.
	* **$O(1)$ (Constant):** 200px/s speed, 22px collider, Zero inertia, 0.0s lag.
* **RAM Gauge (Health):** A survival timer/health bar. Touching Technical Debt (enemies) or staying unoptimized generates "heat" and fills the RAM.
* **Technical Debt (Enemies):**
	* **Spaghetti Code ($O(2^n)$):** Slow tangler. Shoots tether cables that drag the player.
	* **Memory Leak ($O(n^2)$):** Drifting blob. Grows over time, filling RAM on contact.
	* **Null Pointer:** Fast darter. Blinks in/out of existence. Hard to dodge.
	* **Infinite Loop:** Orbits the arena. Creates inescapable gravity wells.
	* **Stack Overflow:** Stacks up. Becomes a giant crushing wall of nested blocks.
	* **Race Condition ($O(n)$):** Twin pair that chase simultaneously from opposite directions.
* **Clean Code Packets (Collectibles):**
	* **Refactor Packet:** Core drop. Lowers tier by one step.
	* **Big-O Shortcut:** Rare. Skips two tiers instantly.
	* **Cache Hit:** Temp speed boost. Max velocity for 5 seconds.
	* **Kernel Fragment:** End-game. Collecting all 3 triggers $O(1)$ transition.
* **The "Zombie Fork":** "Throw your child to death; his ghost lingers in your system, bloating your execution."
	* **Mechanism:** Split off a ghostly child process (low opacity, rapid decay).
	* **Benefit:** Instantly dumps 20% of RAM heat (Process Flush).
	* **Penalty:** The parent thread is forced into a *less efficient* (slower/heavier) Big O tier as "Zombie Overhead." Locked at $O(2^n)$.
* **Brainrot Shaders:** Visual "Deep-Fry" filters, chromatic aberration, and screen shakes that intensify as the system nears a crash.
* **The $O(1)$ Singularitoy:** Reaching the final tier triggers an automatic win sequence where the player deletes the entire screen.

---

## Technical Architecture
* **Entity Component System (ECS) Hybrid:** 
	* Entities use dedicated components (`MovementComponent`, `VisualsComponent`, `ComplexityManager`) for modular logic.
	* Decoupled communication via Signals (e.g., `thread_forked` for spawning projectiles).
* **Zero-Allocation Physics:**
	* `MovementComponent` uses `PackedFloat64Array` and `PackedVector2Array` to track input history, ensuring zero garbage allocation during the critical physics loop.
* **Event-Driven UI:**
	* Managers (e.g., `BackgroundManager`) initialize connections in `_ready()` and react to signals, avoiding expensive per-frame polling.
* **Scene Hierarchy:**
	* `World` acts as the composition root.
	* `Projectiles` container decouples spawned entities from their parents.
	* `SectorManager` handles infinite grid generation.

---

## Interface
* **Input:** Mouse (Primary), Keyboard (Secondary).
* **Controls:**
	* **Mouse Move:** Algorithm drifts toward the cursor (Inertia and Input Lag depend on tier).
	* **Spacebar:** Activate "Zombie Fork" (Heat Dump vs. System Bloat).
* **UI:** Minimalist terminal-style HUD with a live "Complexity Readout" and a vertical neon RAM gauge.

---

## Art Style
**Aesthetic:** "Terminal Brainrot." A mix of high-end cyber-hacker visuals and distorted, low-quality meme energy.
* **References:** The clean grids of *Agar.io*, the chaotic particle effects of *Vampire Survivors*, and the glitch-aesthetic of *Cyberpunk 2077*.
* **Visual Evolution:** $O(2^n)$ is red, shaky, and pixelated; $O(1)$ is pure white, glowing, and high-definition.



---

## Music / Sound
* **Dynamic Bitrate:** The background track is "bass-boosted" and muffled at high complexity, becoming clear and melodic as the player optimizes.
* **SFX:** * "Vine Thud" on heavy collisions.
	* Mechanical keyboard "clacks" for UI interaction.
	* Windows XP-style error sounds when the RAM gauge is critical.
* **Emotional Goal:** Transition from "Anxious Chaos" to "Calculated Power."

---

## Development Roadmap / Launch Criteria
**Platform:** Web (itch.io) / PC  
**Audience:** CS Students, Indie gamers, Memers (Ages 15–30)

* **Milestone 1: Logic Core** – Tier-switching system and scale-based movement logic. (Completed)
* **Milestone 2: Debt AI** – Spaghetti Code "tether" physics and Swarm spawning. (In Progress)
* **Milestone 3: Visual Identity** – RAM Gauge UI and "Deep-Fry" shader implementation. (0/0/00)
* **Milestone 4: Polish** – Victory sequence at $O(1)$ and sound design. (0/0/00)

**Launch Day:** June 15, 2026
