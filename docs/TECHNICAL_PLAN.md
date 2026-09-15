# Technical Plan — Creature MMO

## 1. Engine & base framework

- **Engine**: Unity (LTS).
- **Base framework**: [OpenMMORPG](https://github.com/open-mmorpg/OpenMMORPG) — free, community-maintained, open-source Unity MMO framework (continuation of MmoKitCE / SURIYUN's MMORPG Kit). Provides baseline systems we don't want to build from scratch:
  - Character movement/networking sync
  - Inventory & equipment
  - Basic combat/skill framework
  - Zone/scene transitions
  - Account/login flow

We use it as **plumbing only**. All creature/capture/evolution systems, world content, art, and combat abilities are original work built on top.

## 2. License & IP hygiene

- Track OpenMMORPG's license terms in `THIRD_PARTY_NOTICES.md` (to add once we vendor it in) and keep our original code/assets clearly separated from the base framework's files.
- No assets, code, or text from any commercial monster-taming MMO (including Digimon Masters Online) are to be used, referenced, or reverse-engineered anywhere in this repo.

## 3. Networking architecture

- Authoritative server, client-predicted movement.
- World split into **Shard instances**: each Shard (zone) runs as its own server process; players are routed between Shard servers via a lightweight matchmaking/gateway service. This avoids building single-world seamless sharding (out of reach for a 3–10 person team) while still feeling like one persistent world.
- Dungeons/world-boss instances spun up on demand, capped at a fixed party/raid size.

## 4. Backend services (outside Unity)

- **Auth service**: account creation/login, session tokens.
- **Persistence service**: character data, roster/creature data, inventory — Postgres.
- **Session/zone state**: Redis (who's online, which Shard/instance a player is in).
- **Auction house / trading service**: separate from real-time game servers; can be simpler REST + Postgres.

## 5. Hosting

- Dedicated Unity server builds deployed via a managed fleet service (e.g. Unity Multiplay or an equivalent container-based orchestrator) rather than hand-rolled server orchestration.
- Start with a single low-cost VM for the MVP (one Shard, ~20–50 concurrent players); move to managed fleet scaling once past MVP.

## 6. Build order (phased, gated)

1. **Vertical slice (single-player feel)**: core loop playable locally — walk around, encounter wild creature, capture it, level it, evolve it, fight another creature. No networking yet.
2. **Add dedicated server + basic backend**: same slice, now client connects to a real dedicated server; auth + save/load character & roster via Postgres.
3. **Scale to MVP target (~20–50 concurrent players in one Shard)**: stress test, fix desync/latency issues, add 1 dungeon instance.
4. **Second Shard + travel between them**: validates the multi-Shard routing approach.
5. **PvP arenas, auction house, guilds**: only after the core loop is proven fun in playtests.

## 7. Repo layout (proposed)

```
/client        Unity project (OpenMMORPG-based client)
/server        Dedicated server build config + game server logic
/backend       Auth, persistence, auction house services
/docs          Design docs (this folder)
/art           Original creature/environment art source files
```

This structure will be filled in as we vendor OpenMMORPG and start implementing systems.
