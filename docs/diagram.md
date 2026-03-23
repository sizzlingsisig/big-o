# Architecture Diagrams: Big O: Technical Debt

This document provides visual representations of the system architecture using Mermaid diagrams.

## 1. System Overview (Node & Component Structure)

This diagram shows the relationships between the Player, its components, the Global Event Bus, and major game managers.

```mermaid
graph TD
    subgraph Singletons [Global Systems]
        GE[GameEvents]
        SFX[ScreenFX]
        CM[CollectiblePoolManager]
    end

    subgraph PlayerEntity [Player: CharacterBody2D]
        P[player.gd]
        MC[MovementComponent]
        VC[VisualsComponent]
        SRC[SystemResourcesComponent]
        CXM[ComplexityManager]
    end

    subgraph Config [Data Resources]
        PCR[PlayerComplexity Resource]
    end

    subgraph UI_Layer [User Interface]
        HUD[HUD.tscn]
        GOS[GameOver.tscn]
    end

    %% Player Component Connections
    P --> MC
    P --> VC
    P --> SRC
    P --> CXM

    %% Complexity & Data
    CXM -.-> PCR
    CXM -- "complexity_changed" --> VC
    MC -- "uses" --> PCR

    %% Event Bus Communication
    SRC -- "ram_changed" --> GE
    CXM -- "tier_changed" --> GE
    P -- "state_changed" --> GE
    
    GE -- "observes" --> HUD
    GE -- "observes" --> GOS

    %% World Interactions
    CM -- "spawns" --> COL[Collectibles]
    ES[EnemySpawner] -- "spawns" --> EN[Enemies]
    
    COL -- "on_collect" --> CXM
    EN -- "on_hit" --> P
```

---

## 2. Optimization Sequence Diagram

This diagram illustrates the flow from collecting a "Clean Code Packet" to a successful "Refactor" (Tier Upgrade).

```mermaid
sequenceDiagram
    participant C as Collectible
    participant CXM as ComplexityManager
    participant P as Player (player.gd)
    participant VC as VisualsComponent
    participant HUD as HUD (UI)

    C->>CXM: add_optimization_fragment(amount)
    CXM->>CXM: Update current_fragments
    CXM-->>HUD: [GameEvents] optimization_fragments_updated
    
    Note over CXM: If Meter Full
    
    CXM->>P: [Signal] optimization_ready
    P->>P: start_processing()
    P->>P: _change_state(PROCESSING)
    P->>VC: set_state(PROCESSING)
    VC->>VC: apply_processing_effect()
    
    Note over P: Wait for Processing Timer
    
    P->>CXM: complete_refactor()
    CXM->>CXM: current_index += 1
    CXM->>CXM: set_tier(new_index)
    CXM-->>P: [Signal] complexity_changed
    CXM-->>VC: [Signal] complexity_changed
    CXM-->>HUD: [GameEvents] complexity_tier_changed
    
    P->>P: _change_state(IDLE)
```

---

## 3. Player State Machine

```mermaid
stateDiagram-v2
    [*] --> IDLE
    
    IDLE --> PROCESSING: optimization_ready
    PROCESSING --> IDLE: timer_complete
    PROCESSING --> IDLE: interrupted (damage)
    
    IDLE --> FORKING: space_pressed
    FORKING --> IDLE: timer_complete
    
    IDLE --> ERROR: take_damage
    ERROR --> IDLE: timer_complete
    
    IDLE --> DISRUPTED: external_effect
    DISRUPTED --> IDLE: timer_complete
    
    IDLE --> DEAD: ram_overflow
    ERROR --> DEAD: ram_overflow
    DEAD --> [*]
```
