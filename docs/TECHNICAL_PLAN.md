# Technical Plan — Creature MMO

## 1. Stack (current — forked from t5c)

The engineering base is **[t5c](https://github.com/orion3dgames/t5c)** (MIT license), an open-source multiplayer 3D RPG. We forked it wholesale rather than building an MMO engine from scratch — verified working end-to-end (login, movement, inventory, abilities, quests, vendors) before adopting it, and again after moving it into this repo. See root `README.md` for the "why" and attribution requirements.

- **Client**: Babylon.js + webpack. Entry point `src/client/index.ts`. Diablo-style click-to-move + WASD, animated characters (VAT), draggable UI panels, inventory/equipment, chat.
- **Server**: Node.js + Colyseus (authoritative rooms) + Express (REST endpoints for game data/auth). Entry point `src/server/index.ts`.
- **Persistence**: SQLite by default (`database.db`, auto-created from `database/sqllite.sql` on first run), MySQL supported via `src/shared/Config.ts`.
- **Shared**: `src/shared/` — config and types used by both client and server.

This replaces two earlier iterations tried in this project: a Unity + OpenMMORPG plan (dropped — no way to run/test Unity in this dev environment) and a from-scratch Node/Prisma/Three.js/Colyseus stack (dropped in favor of t5c once we found it already has the systems we were about to spend weeks building — quests, inventory, vendors, leveling, combat AI).

## 2. What's inherited from t5c (already working, verified)

- Player-authoritative movement with client-side prediction + server reconciliation
- Login/register/character selection scene flow
- Map management incl. teleporting between maps (zones)
- Multiplayer animated characters, global chat
- Navmesh-based collision
- Enemy AI (IDLE/PATROL/CHASE/ATTACK/DEAD) with loot drops
- 4 abilities (sword attack, fireball, DOT, heal), targeting system
- Inventory, equipment (visible on character), pickup
- Leveling (XP + ability points)
- Quest system, trainer system (learn abilities), vendor system (buy/sell)

Verified twice: once running standalone from the upstream clone, once again after moving the code into this repo (headless-browser screenshots both times — see session history, not re-attached here to keep the repo lean).

**Data-driven content lives in `src/server/data/`** — this is where reskinning work happens:
- `RacesDB.ts` — character/creature race definitions → where our Emergent species (Duskwyrm, Wyrmling, etc., `art/creatures/species/`) get wired in
- `AbilitiesDB.ts` — abilities → where creature-type-based abilities (`docs/GAME_DESIGN.md` §4.1 elemental types) get defined
- `ItemDB.ts` — items → evolution catalysts, gear
- `LocationsDB.ts` — zones/maps → our Shards (`docs/WORLD_LORE.md` §2) and Origin hub
- `QuestsDB.ts` — quests → `docs/QUESTLINE_ACT1.md`'s MQ01-MQ17/SQ/BQ content

## 3. Known gotcha (from getting this running — read before touching networking)

The client's dev/production URL check (`src/client/Utils/index.ts`, `isLocal()`) does a literal string match on `window.location.host === "localhost:8080"`. Opening the client via `127.0.0.1:8080` instead of `localhost:8080` fails this check silently and makes the client try to reach a production-style HTTPS URL instead of the local server (visible as `ERR_CONNECTION_REFUSED`/`AxiosError` in the console, game stuck on the loading screen). Always use `http://localhost:8080`, not `127.0.0.1`.

## 4. Immediate next steps — reskinning into the creature-taming game

This is the actual work now: t5c gives us a generic fantasy RPG (races are humanoid classes, not creatures). Turning it into the design in `docs/GAME_DESIGN.md` means:

1. **Capture mechanic**: new ability/interaction type added alongside the 4 existing abilities, targeting a wild spawn instead of a hostile enemy, resulting in a roster addition instead of damage — backs quest MQ05 (`docs/QUESTLINE_ACT1.md`).
2. **Species as "races"**: replace/extend `RacesDB.ts` entries with our creatures (Duskwyrm now, more species as designed/sourced), including evolution-tier data (t5c doesn't have an evolution concept — new field/system needed).
3. **Player roster**: t5c's player controls one character directly; our design has a player (Anchor) commanding an active creature (Emergent) from a roster. This is the biggest structural change — likely a player-controls-active-pet pattern layered on top of t5c's existing player-entity code rather than a full rewrite.
4. **World reskin**: rename/reflavor `LocationsDB.ts` zones into Shards, add Origin as the hub (t5c already has a town/hub map concept to adapt).
5. **Quest content**: implement `docs/QUESTLINE_ACT1.md`'s MQ01-17 using t5c's existing quest system rather than building a new one.
6. **Real monster models**: swap t5c's default race/enemy models for the Quaternius pack (`art/creatures/quaternius-animated-monster-pack/`) and Duskwyrm (`art/creatures/sources/oscar-creativo-dragon/`) — need conversion/import into Babylon.js's expected format (t5c uses glTF with VAT — vertex animation textures — for instanced animated characters, check `construction/Models` and `public/models` for the expected pipeline before just dropping in raw glTF).

## 5. Hosting

Not yet addressed — everything runs locally in this dev environment. Before real deployment: pick a host for the Node server (SQLite means no separate DB service to provision, which simplifies this versus the earlier Postgres-based plan), decide on a CDN/static host for the webpack client build, and add the required t5c/Orion3d credit to a real credits screen per the MIT license.

## 6. Local dev setup

```
npm install
npm run server-dev   # server on :3000, Colyseus monitor at :3000/monitor
npm run client-dev   # client on :8080 — open via http://localhost:8080, not 127.0.0.1 (see §3)
```
