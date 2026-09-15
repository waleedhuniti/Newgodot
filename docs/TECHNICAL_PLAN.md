# Technical Plan — Creature MMO

## 1. Stack (revised — no Unity)

Original plan called for Unity + OpenMMORPG. That's dropped: nobody on this project can actually run/test a Unity project inside this development session (it needs an interactive editor GUI), which meant every "Unity" deliverable was untestable documentation, not working software. The stack below is chosen specifically so the **server and backend are real, running, tested code** — see §2, all of which is implemented and verified working as of this revision.

- **Backend API** (`/backend`): Node.js + TypeScript + Express + Prisma + PostgreSQL. Handles auth, accounts, characters, species definitions, and creature persistence.
- **Realtime game server** (`/realtime`): Node.js + TypeScript + [Colyseus](https://colyseus.io/) (MIT-licensed, open-source authoritative multiplayer server framework). Each **Shard** (docs/WORLD_LORE.md §2) is a Colyseus room — one process can host many Shard instances.
- **Shared types** (`/shared`): TypeScript types/interfaces used by both backend and realtime, so message shapes can't drift out of sync between them.
- **Session/zone state**: Redis (installed and running; not yet wired into code — tracked as follow-up in §6).
- **Client** (`/client`): browser/WebGL, Three.js + Colyseus's JS client SDK + Vite. Implemented and verified running (see §2) — a native engine client remains an option later, but this is no longer blocking.

## 2. What's actually built and verified working

As of this revision, the following has been implemented, run, and tested end-to-end in this environment (not just designed):

- **Auth**: `POST /auth/register`, `POST /auth/login` — bcrypt password hashing, JWT issuance. Verified via live HTTP requests.
- **Species data**: Prisma model + seed script. `wyrmling` (Tier 1) and `duskwyrm` (Tier 3, see `art/creatures/species/duskwyrm.md`) are seeded, with an `evolvesFrom` relation between them.
- **Character creation**: `POST /characters` creates a character and bonds its starter creature in one transaction (this is the backend for quest MQ05 in `docs/QUESTLINE_ACT1.md`). `GET /characters` lists a account's characters with their creatures.
- **Realtime shard room**: a Colyseus `ShardRoom` (`realtime/src/rooms/ShardRoom.ts`) that authenticates joining clients via the JWT issued by the backend (`onAuth`), tracks each connected player in shared schema state (position, rotation, name), and relays `move` messages. **Verified with two independent simulated clients**: both see each other in shared state, and one client's movement is observed by the other in real time.
- **Web client** (`/client`): Three.js + Colyseus JS client + Vite. Login/register form → backend auth → character creation/lookup → joins the realtime Shard room → renders a 3D scene (ground plane, placeholder monster-spawn markers, a capsule mesh per connected player) with WASD movement and a follow camera. **Verified visually with a headless browser (Playwright + the pre-installed Chromium)**: two separate browser sessions logged in as different accounts, both correctly see both players moving in real time in the same Shard, screenshotted as proof.

None of this required Unity or any GUI tool — it was written, run, and tested directly via `curl`, small Node test scripts, and headless-browser screenshots in this session.

### Known trap already hit and fixed (documented so it doesn't get re-hit)

`@colyseus/schema` v2's `@type()` decorators silently stop working — no error, sync just does nothing — if TypeScript's `useDefineForClassFields` is left at its default (`true` under an `ES2022`+ target). Fixed by setting `"useDefineForClassFields": false` in `realtime/tsconfig.json`. If schema sync ever silently breaks again after a tsconfig or TS-target change, check this first.

## 3. Networking architecture

- Authoritative server: the Colyseus room is the source of truth for position and (future) combat state; clients send intent (`move`, later `capture_attempt`, ability use, etc.) and receive authoritative state back.
- World split into **Shard instances**: each Shard (docs/WORLD_LORE.md §2) is a room definition/instance (`gameServer.define("shard_name", ShardRoom)`), not a whole separate server process — Colyseus multiplexes many rooms over one Node process, so adding Shards is cheap until real scale requires splitting across processes/machines.
- Dungeons/world-boss instances: modeled the same way — a room per instance, spun up on demand, capped at a fixed party/raid size (not yet implemented, same `Room` pattern as `ShardRoom`).

## 4. Backend services

- **Auth service**: implemented (`backend/src/routes/auth.ts`).
- **Persistence service**: implemented via Prisma/Postgres (`backend/prisma/schema.prisma`) — accounts, characters, species, creature instances.
- **Session/zone state**: Redis is installed and running but not yet wired in — needed once there's more than one Shard, to route a reconnecting player to the right room and track presence.
- **Auction house / trading service**: not started — post-MVP per `docs/GAME_DESIGN.md` §9.

## 5. Hosting

Not yet addressed — everything above runs locally in this dev environment (Postgres, Redis, backend, and realtime server all running as local processes/services). Before any real deployment: containerize `backend` and `realtime` separately, pick a managed Postgres + Redis provider, and decide on a Node hosting target (a plain VPS is enough for the MVP's ~20-50 concurrent player target — no need for Kubernetes or a game-specific fleet manager at this scale).

## 6. Immediate next steps (in rough order)

1. Replace placeholder cone/capsule geometry with real map and monster models once sourced (client's `scene.ts` isolates this to one file).
2. Add a `capture_attempt` message handler to `ShardRoom`, backing quest MQ05/the capture mechanic (`docs/GAME_DESIGN.md` §4.2) with real wild-spawn state — the client already has click/interact room to add this.
3. Wire Redis into the realtime server for session/presence tracking (currently each Shard room only knows about its own connected clients).
4. Persist creature position/roster changes from the realtime server back through the backend API (right now movement is synced live but not saved — a disconnect loses position, which is fine for MVP but should be flagged).
5. Docker Compose for local dev (Postgres + Redis + all three Node services) so a new team member doesn't have to manually install/start services like this session did.

## 7. Repo layout (current, not proposed)

```
/backend       Express + Prisma REST API — auth, characters, species (IMPLEMENTED)
/realtime      Colyseus authoritative game server — ShardRoom (IMPLEMENTED)
/client        Three.js + Vite web client (IMPLEMENTED, placeholder art)
/shared        Shared TypeScript types between backend and realtime (IMPLEMENTED)
/docs          Design docs (this folder)
/art           Creature/environment art sources
```

## 8. Local dev setup

See `backend/README.md` and `realtime/README.md` for exact run commands. Summary: Postgres and Redis must be running locally, `backend/.env` configured from `.env.example`, `npm install` at the repo root (npm workspaces), `npx prisma migrate dev` + `npx prisma db seed` in `backend/`, then `npm run dev:backend` and `npm run dev:realtime` from the repo root (each in its own terminal/process).
