---
name: mermaid-diagrams
description: Comprehensive guide for creating software diagrams using Mermaid syntax. Use when users need to create, visualize, or document software through diagrams including class diagrams, sequence diagrams, flowcharts, ERDs, C4 architecture diagrams, state diagrams, or any other diagram type. Triggers include requests to "diagram", "visualize", "model", "map out", "show the flow".
---

# Mermaid Diagramming

Create professional software diagrams using Mermaid's text-based syntax.

## Diagram Type Selection

| Type | Use For |
|------|---------|
| Class Diagrams | Domain modeling, OOP design, entity relationships |
| Sequence Diagrams | API flows, auth sequences, component interactions |
| Flowcharts | User journeys, processes, algorithms, pipelines |
| ERD | Database schemas, data modeling |
| C4 Diagrams | System architecture at multiple levels |
| State Diagrams | State machines, lifecycle states |

## Quick Examples

### Class Diagram
```mermaid
classDiagram
    User --> Order : places
    Order *-- OrderItem

    class User {
        +string email
        +create_order()
    }
```

### Sequence Diagram
```mermaid
sequenceDiagram
    participant User
    participant API
    participant DB

    User->>API: POST /login
    API->>DB: Query credentials
    DB-->>API: User data
    alt Valid
        API-->>User: 200 + JWT
    else Invalid
        API-->>User: 401
    end
```

### Flowchart
```mermaid
flowchart TD
    Start([Visit]) --> Auth{Logged in?}
    Auth -->|No| Login[Login page]
    Auth -->|Yes| Dashboard[Dashboard]
    Login --> Validate{Valid?}
    Validate -->|Yes| Dashboard
    Validate -->|No| Error[Error] --> Login
```

### ERD
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains

    USER {
        int id PK
        string email UK
    }
```

## Syntax Reference

**Comments:** `%% This is a comment`

**Relationships (Class):**
- `A -- B` Association
- `A --> B` Directed
- `A *-- B` Composition
- `A o-- B` Aggregation
- `A <|-- B` Inheritance

**Arrows (Sequence):**
- `->>` Sync request
- `-->>` Sync response
- `--)` Async

**Shapes (Flowchart):**
- `[Rectangle]`
- `([Stadium])`
- `{Diamond}`
- `((Circle))`

## Best Practices

1. Start simple, add details incrementally
2. One concept per diagram
3. Use meaningful names
4. Comment complex relationships with `%%`
5. Store `.mmd` files alongside code

## Rendering

Native support: GitHub, GitLab, VS Code, Notion, Obsidian

Export: [Mermaid Live Editor](https://mermaid.live) or CLI `mmdc -i input.mmd -o output.png`
