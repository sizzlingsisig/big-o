# Architecture Diagrams: Big O: Technical Debt

This document provides visual representations of the system architecture using Mermaid diagrams.

## 1. System Overview (Node & Component Structure)

This diagram shows the relationships between the Player, its components, the Global Event Bus, and major game managers.

```mermaid
graph TD
    %% High Contrast Styling
    classDef core fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000;
    classDef aux fill:#ffffff,stroke:#64748b,stroke-width:2px,color:#000;

    subgraph World_Systems [World & Game Logic]
        CM[CollectiblePoolManager]
        ES[EnemySpawner]
    end
    class CM,ES core;

    subgraph Global_Bus [Communication Hub]
        GE[GameEvents Singleton]
    end
    class GE core;

    subgraph Player_Entity [Player Container]
        P[player.gd]
        MC[MovementComponent]
        VC[VisualsComponent]
        SRC[SystemResourcesComponent]
        CXM[ComplexityManager]
    end
    class P,MC,VC,SRC,CXM core;

    subgraph Config_Data [Resources]
        PCR[PlayerComplexity .tres]
    end
    class PCR aux;

    subgraph UI_Layer [User Interface]
        HUD[HUD / Overlay]
        GOS[GameOver / BSOD]
    end
    class HUD,GOS aux;

    %% Logic Connections (Direct Calls)
    P -->|Manages| MC
    P -->|Manages| VC
    P -->|Manages| SRC
    P -->|Manages| CXM
    
    CXM -->|Applies| PCR
    MC -->|Reads| PCR

    %% Event Bus Flow (Signals)
    SRC -.->|ram_changed| GE
    CXM -.->|tier_changed| GE
    CXM -.->|optimization_progress| GE
    P -.->|state_changed| GE
    
    GE -.->|Signal| HUD
    GE -.->|Signal| GOS

    %% World Interactions
    CM -->|Spawns| COL[Collectibles]
    ES -->|Spawns| EN[Enemies]
    
    COL -->|on_collect| CXM
    EN -->|on_hit| P

    %% Legend
    subgraph Legend
        L1[Blue = Core Logic]
        L2[White = Supporting/UI]
        L3[Solid Line = Direct Call]
        L4[Dashed Line = Signal/Event]
    end
```

---

## 2. Refactor & Optimization Flow

This sequence diagram detail the steps from collecting a packet to successfully upgrading the Big O complexity tier.

```mermaid
sequenceDiagram
    autonumber
    participant C as Collectible
    participant CXM as ComplexityManager
    participant GE as GameEvents (Bus)
    participant P as Player (player.gd)
    participant HUD as HUD (UI)

    C->>CXM: add_optimization_fragment(amount)
    CXM->>CXM: Increment current_fragments
    CXM-->>GE: optimization_fragments_updated(curr, req)
    GE-->>HUD: Update optimization meter
    
    Note over CXM: If fragments >= required
    
    CXM->>P: Signal: optimization_ready
    P->>P: _change_state(PROCESSING)
    P-->>GE: player_state_changed(PROCESSING)
    
    Note over P: Wait for complexity.get_processing_time()
    
    P->>CXM: complete_refactor()
    CXM->>CXM: index += 1
    CXM->>CXM: set_tier(index)
    
    CXM-->>GE: complexity_tier_changed(new_tier)
    GE-->>HUD: Update Tier Label & Physics UI
    
    P->>P: _change_state(IDLE)
```

---

## 3. Player State Machine

```mermaid
stateDiagram-v2
    state "IDLE (Normal Play)" as idle
    state "PROCESSING (Refactoring)" as proc
    state "ERROR (Stunned)" as err
    state "FORKING (Zombie Fork)" as fork
    state "DISRUPTED (Control Glitch)" as glitch
    state "DEAD (BSOD)" as dead

    [*] --> idle
    
    idle --> proc: fragments full
    proc --> idle: timer finished
    proc --> idle: interrupted (took damage)
    
    idle --> fork: Space pressed
    note right of fork: Invulnerable state
    fork --> idle: duration finished
    
    idle --> err: hit by enemy
    err --> idle: duration finished
    
    idle --> glitch: heisenberg/spaghetti effect
    glitch --> idle: duration finished
    
    idle --> dead: RAM reaches 100%
    err --> dead: RAM reaches 100%
    proc --> dead: RAM reaches 100%
    dead --> [*]
```
