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

**On top of that, our own tutorial content is built and verified working end-to-end**: register/login → create character → spawn in a tutorial zone → approach an NPC → accept a quest → return and complete it for a reward. Concretely:
- `arrival_clearing` — a new Location (`src/server/data/LocationsDB.ts`) matching "Arrival" in `docs/STORY.md` §1 / MQ01-03 in `docs/QUESTLINE_ACT1.md`. Reuses the `training_ground` map mesh as placeholder geometry (see §4.4).
- `MQ_FIRST_CONTACT` ("The Bond") — a new Quest (`src/server/data/QuestsDB.ts`) matching MQ04/MQ05. Talk to the Wyrmling NPC once to accept, talk again to complete — stands in for the real capture mechanic (§4.1) until that's built.
- New characters now spawn in `arrival_clearing` instead of the default town (`src/server/Database.ts`), and the client always starts at the login screen now (`src/client/index.ts` — it used to skip straight to gameplay when running locally, a dev shortcut that was hiding this whole flow).

**Data-driven content lives in `src/server/data/`** — this is where reskinning work happens:
- `RacesDB.ts` — character/creature race definitions → where our Emergent species (Duskwyrm, Wyrmling, etc., `art/creatures/species/`) get wired in
- `AbilitiesDB.ts` — abilities → where creature-type-based abilities (`docs/GAME_DESIGN.md` §4.1 elemental types) get defined
- `ItemDB.ts` — items → evolution catalysts, gear
- `LocationsDB.ts` — zones/maps → our Shards (`docs/WORLD_LORE.md` §2) and Origin hub
- `QuestsDB.ts` — quests → `docs/QUESTLINE_ACT1.md`'s MQ01-MQ17/SQ/BQ content

## 3. Known gotchas (found getting this running — read before re-hitting them)

- **Open the client via `http://localhost:8080`, not `127.0.0.1`.** The client's dev/production URL check (`src/client/Utils/index.ts`, `isLocal()`) does a literal string match on `window.location.host === "localhost:8080"`. Failing it silently makes the client try to reach a production-style HTTPS URL instead of the local server (`ERR_CONNECTION_REFUSED`/`AxiosError` in the console, game stuck on the loading screen).
- **A `Location` entry's `key` and `mesh` are different things — use the right one.** Every location shipped with t5c happened to have `key === mesh`, which hid three separate bugs where code used `.key` to build an asset file path when it should have used `.mesh` (so a location can reuse another's map/navmesh without a duplicate file per location, per §4.4 below): `src/server/rooms/GameRoom.ts` (server navmesh), `src/client/Screens/GameScene.ts` (client navmesh *and* environment mesh loading — two separate spots). All three are fixed and commented; if a new location reusing an existing mesh throws a 404/"Not Found" loading its navmesh or environment, check here first.
- **`src/shared/Libs/yuka-min.js` was missing its `Logger` class** (present in the companion `yuka-full.js` but not carried into this trimmed bundle) — a few rarely-hit error paths (`NavMeshLoader`, `Polygon`) call `Logger.error(...)`, which threw `ReferenceError: Logger is not defined` and hard-crashed the client the first time one of those paths actually ran. Fixed by adding a minimal `Logger` mirroring the full version.
- **`RacesDB.ts` is missing a `rat_01` entry** even though `training_ground` and `lh_dungeon_01`'s spawns reference `race: "rat_01"` — a pre-existing gap (not something we introduced) that crashes `VatController.prepareVat` (`Cannot read properties of undefined (reading 'key')`, since the race object it gets back has no `.vat` field) the moment a `rat_01` spawn actually needs to load. Avoid `rat_01` for new spawns until someone adds real race data for it; `skeleton_01` is a complete, proven-working substitute.
- **The shared `Quest` type was mistyped**: `type: QuestObjective.KILL_AMOUNT` (a single literal) instead of `type: QuestObjective` (the enum) in `src/shared/types.ts`. This silently blocked ever using `QuestObjective.TALK_TO` — TypeScript would flag any comparison against it as "no overlap" — which is almost certainly why TALK_TO was defined but never finished upstream. Fixed, and TALK_TO's completion logic (which was stubbed as dead code — `isQuestReadyToComplete` only ever handled KILL_AMOUNT) is now implemented on both `src/client/.../QuestDialog.ts` and `src/server/rooms/controllers/dynamicCTRL.ts`: talking to the quest giver again after accepting completes it, no separate kill/visit target needed.
- **Babylon's canvas needs an explicit `tabIndex` + `.focus()` before Playwright (or any programmatic input) can type into its GUI `InputText` fields.** A plain `mouse.click()` on the field isn't enough — keyboard events won't reach it. Not a game bug, just a headless-testing note.
- **Movement is click-and-hold, not click-to-pathfind**, despite the README calling it "diablo like": `PlayerInput.ts` only moves the player while the mouse button is physically down (`POINTERDOWN` starts it, `POINTERUP` stops it). A quick click does nothing. Also not a bug, just not what the name suggests.

## 4. Reskinning into the creature-taming game — status

t5c gives us a generic fantasy RPG (races are humanoid classes, not creatures). Turning it into the design in `docs/GAME_DESIGN.md`:

1. **Tutorial (MQ01-05)**: **done** (§2 above) — arrival zone, first NPC encounter, accept/complete quest loop proven working.
2. **Capture mechanic**: still a placeholder. MQ_FIRST_CONTACT uses the TALK_TO quest type as a stand-in; a real capture needs a new interaction (probably a new ability/interaction type alongside the 4 existing abilities) that adds to a roster instead of granting XP. Next logical piece of work.
3. **Species as "races"**: replace/extend `RacesDB.ts` entries with our creatures (Duskwyrm now, more species as designed/sourced), including evolution-tier data (t5c doesn't have an evolution concept — new field/system needed).
4. **Player roster**: t5c's player controls one character directly; our design has a player (Anchor) commanding an active creature (Emergent) from a roster. This is the biggest structural change — likely a player-controls-active-pet pattern layered on top of t5c's existing player-entity code rather than a full rewrite.
5. **World reskin**: rename/reflavor `LocationsDB.ts` zones into Shards, add Origin as the hub (t5c already has a town/hub map concept to adapt) — `arrival_clearing` is the first Shard-equivalent zone, more to follow.
6. **Rest of the questline**: `arrival_clearing`/MQ_FIRST_CONTACT covers the tutorial beats; MQ06-17 in `docs/QUESTLINE_ACT1.md` (Origin, Rho, Kess, the dungeon) still need implementing with t5c's quest system.
7. **Real monster models**: swap t5c's default race/enemy models for the Quaternius pack (`art/creatures/quaternius-animated-monster-pack/`), KayKit skeletons (`art/creatures/kaykit-skeletons/`), and Duskwyrm (`art/creatures/sources/oscar-creativo-dragon/`) — need conversion/import into Babylon.js's expected format (t5c uses glTF with VAT — vertex animation textures — for instanced animated characters, check `construction/Models` and `public/models` for the expected pipeline before just dropping in raw glTF). `skeleton_01` (t5c's own stock race) is standing in for Wyrmling right now.
8. **Real map**: `arrival_clearing` reuses the stock `training_ground` mesh — needs a real environment eventually, possibly built from `art/environments/kaykit-dungeon-remastered/`.

## 5. Hosting

Not yet addressed — everything runs locally in this dev environment. Before real deployment: pick a host for the Node server (SQLite means no separate DB service to provision, which simplifies this versus the earlier Postgres-based plan), decide on a CDN/static host for the webpack client build, and add the required t5c/Orion3d credit to a real credits screen per the MIT license.

## 6. Local dev setup

```
npm install
npm run server-dev   # server on :3000, Colyseus monitor at :3000/monitor
npm run client-dev   # client on :8080 — open via http://localhost:8080, not 127.0.0.1 (see §3)
```
