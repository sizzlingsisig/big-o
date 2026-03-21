# Plan: Progression-Based Scaling ("Feature Creep")

This document outlines the implementation for difficulty scaling based on the amount of code processed (XP/Score), representing the mounting technical debt of a growing project.

## 1. Core Concept: "Feature Creep"
Difficulty and system corruption scale with your **Lines of Code (LOC)** processed. The more you "eat" and optimize, the larger the project scope becomes, bringing more aggressive technical debt.

---

## 2. Progression Logic
- **Project Scope (XP)**: A global counter tracking processed code fragments.
- **Difficulty Tiers**:
    - `0 - 500 LOC`: **Alpha Phase** (Easy enemies, stable visuals).
    - `500 - 1500 LOC`: **Beta Phase** (Medium enemies, blue/purple themes).
    - `1500+ LOC`: **Production** (Hard enemies, unstable glitches, red theme).

---

## 3. Implementation Roadmap
- [x] **Step 1: Clean Up** - Remove physical borders and verify infinite camera scroll.
- [ ] **Step 2: Progression Manager** - Implement `ProgressionManager.gd` to track LOC and handle milestones.
- [ ] **Step 3: Feature Creep HUD** - Update HUD to show "Lines of Code" (LOC) as the primary score.
- [ ] **Step 4: Dynamic Visuals** - Re-link background color shifts to LOC milestones (e.g., every 1000 lines).
- [ ] **Step 5: Corruption Scaling** - Update `BackgroundGlitcher` to scale glitch intensity with LOC instead of distance.
