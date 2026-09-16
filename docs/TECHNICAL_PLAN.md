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

**Chapter 3 of the questline (MQ06-MQ07, "Signal from Origin") is also built and verified**: after completing `MQ_FIRST_CONTACT`, a second NPC in `arrival_clearing` — `arrival_dessa_signal` ("Dessa Vail (Signal)") — offers `MQ06_VOICE_FROM_ORIGIN` ("A Voice From Elsewhere"), matching MQ06's dialogue from `docs/QUESTLINE_ACT1.md`. Completing it satisfies a `requires_quest_completed` gate (new field, `dynamicCTRL.ts`) on a `zone_change` interactive point in `arrival_clearing`, which was previously unreachable — this is the "portal to Origin unlocked" reward. Walking through it teleports the player into `lh_town`, which is renamed in-fiction to **Origin** (title only; the internal key stays `lh_town` for save/quest-location compatibility, so this is a reflavor, not a new map — see §4.5). There, `origin_dessa` ("Dessa Vail") offers `MQ07_WELCOME_TO_ORIGIN` ("Welcome to Origin"), same TALK_TO accept/complete pattern, rewarding XP + starting gold. A return `zone_change` sends the player back to `arrival_clearing`. All verified end-to-end via headless-browser screenshots: both quests' full offer → accept → reopen → complete cycles, the gated portal refusing to fire before MQ06 is done and firing correctly after, and the teleport landing exactly on Origin's intended spawn point next to Dessa.

**The Act 1 dungeon now has a real, non-placeholder environment.** `lh_dungeon_01`'s `mesh` points at `shard_dungeon_01` — a stone hall built from KayKit Dungeon Remastered pieces (floor tiles, walls, a doorway, corner/interior pillars, mounted torches, entrance crates, and boss-end dressing: rubble, a gold chest, a wall banner) instead of reusing any stock t5c map. Built by `art/environments/shards/dungeon_01/build.py`, a Blender headless script that assembles the individual glTF pieces on a 4m grid and exports both the visible mesh and a matching flat navmesh plane straight into `public/models/`; re-run it to change the layout (see that file's docstring). Entered via a new always-open `zone_change` in `arrival_clearing` (deliberately not from Origin — see the navmesh gotcha in §3) leading to a modest 3-skeleton fight (tuned down from an initial 8, which was not "soloable at tutorial difficulty" as MQ14 calls for) with a matching return trip. Verified end-to-end: walking there loads the new environment with no errors, the navmesh lets the player move and skeletons path/fight normally, and the return trip works.

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
- **Movement direction is camera-relative, not screen-relative, and the "camera" reference angle (`GameController.deltaCamY`) defaults to `2.7`, not `0`.** `PlayerInput.ts`'s `angle = atan2(x, y)` (mouse position normalized to the canvas, center = origin) feeds `calculateVelocityForces()`, which computes world-space `horizontal`/`vertical` via `sin`/`cos(angle + π − deltaCamY)`. If you need to script a walk toward a specific world point (e.g. Playwright testing), solve `phi = atan2(-dx, dz)` for your desired world delta `(dx, dz)`, then `angle = phi − π + deltaCamY`, then click at screen-normalized `(sin(angle), cos(angle))`. Steady-state speed is roughly 1.8 world units/sec once movement is already underway (the first ~1s is slower — client/server round-trip ramp-up).
- **NPC dialogue interaction is a raycast click on the entity's own mesh** (`Player.ts leftClick()`, `metadata.type === "entity"` + `target.spawnInfo.interactable` + within `PLAYER_INTERACTABLE_DISTANCE`), not a proximity-triggered floating button — `Entity.interactableButtons` is declared but never assigned anywhere in the inherited code, so the `Player.ts` code path that shows/hides it is dead. Clicking near an NPC but missing its mesh doesn't error, it just silently falls through (or, if a dialog panel happens to be open and the click misses its buttons, passes through to whatever's underneath and can re-trigger a fresh `panelDialog.open()` on the same NPC — don't mistake that for a broken quest state).
- **`src/server/utils/loadNavMeshFromFile.ts` passed `Buffer.buffer` straight to the glTF/GLB parser instead of slicing it to the actual file's bounds.** For a Node `Buffer` returned by `fs.readFileSync`, `.buffer` is the *underlying* `ArrayBuffer`, which for small files is a slice of Node's shared ~8KB allocation pool rather than one sized to the file — the parser then reads several KB of unrelated pool memory past the real content as if it were more GLB chunks, and dies with a `JSON.parse` error deep inside `NavMeshLoader`. Every stock navmesh happened to be big enough (tens of KB) to bypass pooling, so this never fired until `shard_dungeon_01`'s navmesh (a simple flat plane, ~1KB) became the first small enough to hit it. Fixed with `data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength)`.
- **Origin's (`lh_town`'s) stock navmesh around the arrival portal's landing spot is a small, oddly-bounded pocket.** Repeated testing (holding movement toward many different screen points, for several seconds each) never got the player more than ~3 units from that landing spot before movement just stopped making progress, well short of the rest of the map's stock content (blacksmith, merchant, etc. at coordinates 20-50+ units away). Never fully root-caused - treat that spot as effectively boxed in for now, and put anything that needs to be reachable from a fresh arrival (like the dungeon entrance) in `arrival_clearing` instead, whose navmesh has no such issue.
- **`ts-node-dev --respawn`'s file watcher can silently stop restarting the server after enough edits in a long session**, with no error - it just keeps running the last successfully-loaded code while `git diff`/`tsc` show your latest changes. Symptom: content edits (new quest text, new locations, gating logic) don't show up in playtesting no matter how correct the code looks, and nothing in the log explains why. Check the log for a `[INFO] ... Restarting: <file> has been modified` line after your last save - if the most recent one is old, kill and restart the dev server process manually.

## 4. Reskinning into the creature-taming game — status

t5c gives us a generic fantasy RPG (races are humanoid classes, not creatures). Turning it into the design in `docs/GAME_DESIGN.md`:

1. **Tutorial (MQ01-05)**: **done** (§2 above) — arrival zone, first NPC encounter, accept/complete quest loop proven working.
2. **Signal from Origin (MQ06-07)**: **done** (§2 above) — gated portal, Origin reflavor, Dessa Vail quest-giver in both places, full accept/complete loop proven working in both locations.
3. **Capture mechanic**: still a placeholder. MQ_FIRST_CONTACT uses the TALK_TO quest type as a stand-in; a real capture needs a new interaction (probably a new ability/interaction type alongside the 4 existing abilities) that adds to a roster instead of granting XP. Next logical piece of work.
4. **Species as "races"**: replace/extend `RacesDB.ts` entries with our creatures (Duskwyrm now, more species as designed/sourced), including evolution-tier data (t5c doesn't have an evolution concept — new field/system needed).
5. **Player roster**: t5c's player controls one character directly; our design has a player (Anchor) commanding an active creature (Emergent) from a roster. This is the biggest structural change — likely a player-controls-active-pet pattern layered on top of t5c's existing player-entity code rather than a full rewrite.
6. **World reskin**: rename/reflavor `LocationsDB.ts` zones into Shards — `arrival_clearing` and `lh_town`/Origin are the first two, more to follow (Rho's dwelling for MQ10+, the arena for MQ12+, the dungeon reflavor for MQ13+).
7. **Rest of the questline**: MQ01-07 done; MQ08-17 in `docs/QUESTLINE_ACT1.md` (the Clearing Surge, Rho, Kess, the dungeon) still need implementing with t5c's quest system.
8. **Real monster models**: swap t5c's default race/enemy models for the Quaternius pack (`art/creatures/quaternius-animated-monster-pack/`), KayKit skeletons (`art/creatures/kaykit-skeletons/`), and Duskwyrm (`art/creatures/sources/oscar-creativo-dragon/`) — need conversion/import into Babylon.js's expected format (t5c uses glTF with VAT — vertex animation textures — for instanced animated characters, check `construction/Models` and `public/models` for the expected pipeline before just dropping in raw glTF). `skeleton_01` (t5c's own stock race) is standing in for Wyrmling right now, and the stock "humanoid" race/`Head_Mage` combo is standing in for Dessa Vail (no "translucent signal" shader built yet for her arrival_clearing appearance).
9. **Real map**: **the dungeon (`lh_dungeon_01`/`shard_dungeon_01`) is done** (§2 above) — a built, populated, verified KayKit environment. `arrival_clearing` and Origin (`lh_town`) still reuse stock t5c meshes; `arrival_clearing` in particular is the next candidate (see `art/environments/README.md` - no outdoor/nature pack sourced yet, only the dungeon kit, so this is blocked on sourcing one).

## 5. Hosting

Not yet addressed — everything runs locally in this dev environment. Before real deployment: pick a host for the Node server (SQLite means no separate DB service to provision, which simplifies this versus the earlier Postgres-based plan), decide on a CDN/static host for the webpack client build, and add the required t5c/Orion3d credit to a real credits screen per the MIT license.

## 6. Local dev setup

```
npm install
npm run server-dev   # server on :3000, Colyseus monitor at :3000/monitor
npm run client-dev   # client on :8080 — open via http://localhost:8080, not 127.0.0.1 (see §3)
```
