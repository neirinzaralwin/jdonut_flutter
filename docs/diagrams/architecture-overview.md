# Architecture Overview

Three layers per feature. Presentation and Data both depend on Domain;
Domain depends on nothing Flutter. The UI only ever reads the local database.

## The big picture

```mermaid
flowchart TB
    subgraph UI[Presentation — what the user sees]
        PAGES[Pages and widgets]
        STATE[Riverpod providers and notifiers]
    end

    subgraph DOMAIN[Domain — pure Dart rules]
        ENT[Entities]
        CONTRACTS[Repository interfaces]
        RULES[Validators and use cases]
    end

    subgraph DATA[Data — where data comes from]
        IMPL[Repository implementations]
    end

    subgraph SOURCES[Storage and network — core]
        DB[(Drift SQLite<br/>single source of truth)]
        SECURE[(Secure storage<br/>session id)]
        API[ApiClient — Dio<br/>/v1 mock server]
        IMG[(Image disk cache)]
        ASSETS[Bundled assets<br/>seed JSON + images]
    end

    PAGES --> STATE
    STATE --> RULES
    STATE --> CONTRACTS
    RULES --> CONTRACTS
    IMPL -. implements .-> CONTRACTS
    IMPL --> DB
    IMPL --> SECURE
    IMPL --> API
    IMPL --> IMG
    ASSETS --> DB
    DB -->|streams| IMPL
```

**Rule of thumb:** arrows never point *up* into Presentation, and nothing in
Domain imports Flutter, Dio, Drift or Riverpod.

## Features and how they talk

```mermaid
flowchart LR
    AUTH[auth<br/>onboarding, phone, OTP,<br/>name, DOB, welcome]
    SHELL[shell<br/>bottom nav + tabs]
    HOME[home<br/>header, carousel,<br/>sections, shops, sync]
    PRODUCT[product<br/>detail, quantity,<br/>add to cart]
    MEMBER[member<br/>one member record]
    SETTINGS[settings<br/>log out]
    REWARDS[rewards<br/>Task 3]

    ROUTER{{core/router<br/>composition root}}

    ROUTER --> AUTH
    ROUTER --> SHELL
    SHELL --> HOME
    SHELL --> REWARDS
    SHELL --> SETTINGS
    HOME -->|tile tap + Hero| PRODUCT
    HOME -->|memberProvider| MEMBER
    REWARDS -.->|same memberProvider| MEMBER
    HOME -->|sessionProvider: name| AUTH
    SETTINGS -->|sessionProvider.logOut| AUTH
```

Features import each other **only through barrels** (`auth/auth.dart`,
`product/product.dart`, `member/member.dart`, …).

## App startup — before the first frame

```mermaid
sequenceDiagram
    participant Main as main.dart
    participant Boot as bootstrap.dart
    participant Seed as SeedService
    participant DB as Drift
    participant Session as Session notifier
    participant Sync as backgroundCatalogSync
    participant App as JDonutApp + GoRouter

    Main->>Boot: bootstrap()
    Boot->>Seed: seedIfNeeded()
    Seed->>DB: first launch only: bundled JSON → tables (1 transaction)
    Boot->>Session: restore()
    Session->>DB: user id from secure storage → user row
    Boot->>Sync: start listening to network status
    Boot->>App: runApp
    App->>App: guard picks Onboarding / Welcome / Home
    Sync-->>DB: when online: refresh catalog in background
```

## Where things live

```mermaid
flowchart TB
    LIB[app/lib]
    LIB --> CORE[core/ — shared infrastructure]
    LIB --> FEAT[features/ — one folder per feature]
    LIB --> L10N[l10n/ — ARB strings]

    CORE --> C1[config · constants · error]
    CORE --> C2[database · storage · network · images]
    CORE --> C3[router · theme · motion · widgets · utils]

    FEAT --> F1[feature/]
    F1 --> D1[domain/ entities · repositories · usecases · validators]
    F1 --> D2[data/ datasources · repositories]
    F1 --> D3[presentation/ pages · widgets · providers]
    F1 --> D4[feature.dart — public barrel]
```
