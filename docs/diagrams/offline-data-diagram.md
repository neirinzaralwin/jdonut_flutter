# Offline Data — File Map (Task 2)

The app works offline from the very first launch. The local Drift database is
the **single source of truth**: the UI only reads Drift streams, and the
network only writes into Drift. Images come from a disk cache, with bundled
assets as the fallback.

## Where data comes from

```mermaid
flowchart LR
    subgraph Bundled[Inside the app]
        SEED[assets/seed/*.json]
        SIMG[assets/images/**]
    end

    subgraph Server[Mock server — optional]
        V1[/v1/products · banners<br/>sections · shops/]
        STATIC[/static/images/**/]
    end

    subgraph Device[On the device]
        DB[(Drift<br/>products · banners · sections<br/>section_products · shops · members)]
        CACHE[(Image disk cache<br/>30 days · 300 files)]
    end

    UI[Home · Product detail · Rewards]

    SEED -->|first launch| DB
    V1 -->|sync| DB
    STATIC -->|prefetch after sync| CACHE
    DB -->|watch streams| UI
    CACHE -->|image| UI
    SIMG -->|fallback image| UI
```

## First launch — seeding

```mermaid
flowchart TD
    START[App opens] --> CHECK{app_meta.seed_version<br/>== SeedService.seedVersion?}
    CHECK -->|yes| DONE[Skip — data already there]
    CHECK -->|no| LOAD[Load products · banners · sections<br/>shops · member JSON from assets]
    LOAD --> TX[One transaction]
    TX --> WRITER[CatalogWriter.replaceCatalog]
    TX --> MEMBER[Insert member record]
    TX --> META[Save seed_version]
    WRITER --> READY[Home renders — no network needed]
    MEMBER --> READY
```

## Sync — refreshing from the server

```mermaid
sequenceDiagram
    participant Trigger as Trigger
    participant Refresh as CatalogRefresh notifier
    participant Repo as CatalogSyncRepositoryImpl
    participant Remote as CatalogRemoteDataSource
    participant Api as ApiClient (Dio)
    participant Writer as CatalogWriter
    participant DB as Drift
    participant Prefetch as ImagePrefetcher

    Note over Trigger: app start online · connection back · pull-to-refresh
    Trigger->>Refresh: refresh()
    Note over Refresh: already running? return the same Future
    Refresh->>Repo: refresh()
    Repo->>Remote: fetchCatalog()
    Remote->>Api: GET /v1/products, /banners, /sections, /shops
    Note over Api: timeouts · retry GET 3× with backoff · never 4xx
    Api-->>Remote: {data, error, meta} → Result
    alt any request failed
        Remote-->>Repo: Err(NetworkFailure / ServerFailure)
        Repo-->>Refresh: Err — cache untouched
    else all four OK
        Repo->>Writer: replaceCatalog(...)
        Writer->>DB: delete + insert in ONE transaction
        DB-->>DB: streams emit once → UI updates
        Repo->>Prefetch: prefetch(image URLs)
        Prefetch->>Prefetch: 4 at a time, failures ignored
        Repo-->>Refresh: Ok
    end
```

Malformed server data (wrong types, missing fields) is caught before or
during the transaction and rolled back — the old cache stays.

## Online or offline?

```mermaid
flowchart TD
    CONN[connectivity_plus change] --> IFACE{Any network<br/>interface?}
    IFACE -->|no| OFF[NetworkStatus.offline]
    IFACE -->|yes| PING[Internet lookup google.com<br/>3 s timeout]
    PING -->|answers| ON[NetworkStatus.online]
    PING -->|fails / times out| OFF

    OFF --> BANNER[ConnectionBanner: dark floating pill<br/>stays while offline]
    ON --> GREEN[Was offline: morphs to green<br/>You're back online → floats away after 3 s]
    ON --> LAUNCH{First status<br/>at launch?}
    LAUNCH -->|yes| HEALTH[GET /v1/health]
    HEALTH -->|answers| CONNECTED[Green toast: Connected to server<br/>floats away after 3 s]
    HEALTH -->|server down| NONE[No toast — saved data]
    ON --> WAS{Was offline<br/>before?}
    WAS -->|yes / first check| SYNC[Background refresh]
```

Why the lookup: connectivity alone says "online" on Wi-Fi with no internet.
This is **device** internet status — a stopped mock server is not "offline";
sync then just fails quietly and keeps the saved data.

## Which image is shown — AppImage

```mermaid
flowchart TD
    START[AppImage assetPath + imageUrl] --> URL{imageUrl set?}
    URL -->|no| ASSET
    URL -->|yes| CACHED{In disk cache?}
    CACHED -->|yes| SHOWCACHE[Show cached file<br/>works offline]
    CACHED -->|no| NET[Download — show bundled asset<br/>as placeholder meanwhile]
    NET -->|success| SHOWNET[Fade in network image<br/>and keep it in cache]
    NET -->|offline / 404| ASSET{assetPath set<br/>and file exists?}
    ASSET -->|yes| SHOWASSET[Show bundled asset]
    ASSET -->|no| LOGO[Grayscale J'Donuts logo<br/>placeholder]
```

## Layer map

```mermaid
flowchart TB
    subgraph Presentation
        HOMEPAGE[HomePage<br/>DonutRefreshControl]
        PROVIDERS[homeBanners · homeSections · nearbyShops<br/>member · productDetail providers]
        REFRESH[CatalogRefresh + backgroundCatalogSync]
        BANNER[ConnectionBanner in app.dart]
    end

    subgraph Domain
        HOMEREPO[HomeRepository]
        SYNCREPO[CatalogSyncRepository]
        PRODREPO[ProductRepository]
        MEMREPO[MemberRepository]
    end

    subgraph Data
        HOMEIMPL[HomeRepositoryImpl]
        SYNCIMPL[CatalogSyncRepositoryImpl]
        REMOTE[CatalogRemoteDataSource]
        PRODIMPL[ProductRepositoryImpl]
        MEMIMPL[MemberRepositoryImpl]
    end

    subgraph Core
        DB[(AppDatabase v3)]
        WRITER[CatalogWriter]
        SEED[SeedService]
        API[ApiClient + dio_smart_retry<br/>with RetryPolicy]
        NET[NetworkStatusMonitor]
        IMG[AppImageCache + ImagePrefetcher]
    end

    HOMEPAGE --> PROVIDERS
    HOMEPAGE --> REFRESH
    PROVIDERS --> HOMEREPO & PRODREPO & MEMREPO
    REFRESH --> SYNCREPO
    REFRESH --> NET
    BANNER --> NET
    HOMEIMPL -. implements .-> HOMEREPO
    SYNCIMPL -. implements .-> SYNCREPO
    PRODIMPL -. implements .-> PRODREPO
    MEMIMPL -. implements .-> MEMREPO
    HOMEIMPL & PRODIMPL & MEMIMPL --> DB
    SYNCIMPL --> REMOTE --> API
    SYNCIMPL --> WRITER --> DB
    SYNCIMPL --> IMG
    SEED --> WRITER
```

## File responsibilities

### Database and seeding

| File | Responsibility |
|---|---|
| `app/lib/core/database/app_database.dart` | Drift DB, schema **v3**. v1→v2 creates the catalog/member/meta tables; v2→v3 adds shop photo columns. |
| `app/lib/core/database/tables/catalog_tables.dart` | Products, Banners, Sections, SectionProducts (ordered links), Shops. |
| `app/lib/core/database/tables/member_tables.dart` | Members (one record) and AppMeta (key/value, e.g. seed version). |
| `app/lib/core/database/seed/seed_mappers.dart` | JSON → Drift rows. Seed files and `/v1` share one shape. Throws `FormatException` on bad data. |
| `app/lib/core/database/catalog_writer.dart` | Replaces the whole catalog in one transaction. Used by seeding **and** sync. |
| `app/lib/core/database/seed/seed_service.dart` | First-launch seeding from `assets/seed/*.json`, guarded by `seed_version`. |
| `app/lib/core/database/database_provider.dart` | `appDatabaseProvider`, `seedServiceProvider`. |

### Network

| File | Responsibility |
|---|---|
| `app/lib/core/config/env.dart` | Server address: `10.0.2.2` on Android emulator, `localhost` on iOS, or `--dart-define=API_BASE_URL`. |
| `app/lib/core/network/api_paths.dart` | `/v1` endpoint paths; turns relative image paths into full URLs. |
| `app/lib/core/network/network_constants.dart` | Timeouts, retry count, backoff base. |
| `app/lib/core/network/api_envelope.dart` | Unwraps `{data, error, meta}` into `Result`. |
| `app/lib/core/network/retry_policy.dart` | Our rules for `dio_smart_retry`'s `RetryInterceptor`: GET only, max 3, never 4xx; delays 400 ms → 1.6 s with jitter. |
| `app/lib/core/network/api_client.dart` | The only HTTP client. Maps every `DioException` to a typed `Failure`. |
| `app/lib/core/network/network_status.dart` | Device internet: a network interface **and** a real lookup within 3 s. Independent of the mock server. |
| `app/lib/core/network/network_providers.dart` | `apiClientProvider`, `networkStatusProvider`. |

### Images

| File | Responsibility |
|---|---|
| `app/lib/core/images/app_image_cache.dart` | Disk cache config (30 days, 300 files). URL is the cache key. |
| `app/lib/core/images/image_prefetcher.dart` | Downloads images after a sync, 4 at a time; failures fall back to assets. |
| `app/lib/core/widgets/app_image.dart` | The one image widget: cache → network → asset → grayscale logo. |

### Feature data and state

| File | Responsibility |
|---|---|
| `app/lib/features/home/data/datasources/catalog_remote_data_source.dart` | Fetches the four `/v1` lists; all must succeed. |
| `app/lib/features/home/data/repositories/catalog_sync_repository_impl.dart` | Remote → `CatalogWriter` → image prefetch; keeps cache on any error. |
| `app/lib/features/home/data/repositories/home_repository_impl.dart` | Watches banners, sections (joined with products, in order) and shops. |
| `app/lib/features/home/presentation/providers/catalog_refresh.dart` | Single-flight refresh + background sync on start / reconnect. |
| `app/lib/features/home/presentation/providers/home_providers.dart` | Stream providers for Home's three data blocks. |
| `app/lib/features/product/data/repositories/product_repository_impl.dart` | Watches one product by id. |
| `app/lib/features/member/data/repositories/member_repository_impl.dart` | Watches the single member record (Home + Rewards). |
| `app/lib/core/widgets/connection_banner.dart` | Toast-like floating pill: green "Connected to server" at launch (only if `/v1/health` answers), dark while offline, green "back online"; green toasts float away after 3 s. |

### Tests

| Test file | Covers |
|---|---|
| `app/test/core/database/seed_service_test.dart` | Seeds once, no duplicates, sections ordered with products. |
| `app/test/core/database/migration_test.dart` | v2 → v3 adds shop photo columns and keeps existing shops. |
| `app/test/features/home/catalog_sync_test.dart` | Replace + delete, image prefetch, offline keeps cache, malformed keeps cache. |
| `app/test/core/network/api_envelope_test.dart` | Envelope success, error code, malformed. |
| `app/test/core/network/retry_policy_test.dart` | When to retry and delay growth. |
| `app/test/core/network/network_status_test.dart` | No interface, Wi-Fi with internet, Wi-Fi without internet. |
| `app/test/core/widgets/connection_banner_test.dart` | Launch toast when the server answers, none when it's down; stays while offline; green then hidden on reconnect. |

## Try it

```sh
# 1. Server off → seeded data + bundled images, offline banner shows
cd app && flutter run
# 2. Server on → banner hides, background sync, images cached
cd mock_server && npm start
# 3. Airplane mode → relaunch → everything still renders
```
