# Creature MMO (working title)

An original creature-collecting MMORPG: capture wild creatures, raise and evolve them, build a team, and battle other players — built entirely with original IP (no Digimon/Pokémon assets, names, or code).

- **Design doc**: [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md)
- **World lore**: [`docs/WORLD_LORE.md`](docs/WORLD_LORE.md)
- **Main story**: [`docs/STORY.md`](docs/STORY.md)
- **Act 1 full questline**: [`docs/QUESTLINE_ACT1.md`](docs/QUESTLINE_ACT1.md)
- **Tech plan**: [`docs/TECHNICAL_PLAN.md`](docs/TECHNICAL_PLAN.md)
- **Stack**: Babylon.js client + Colyseus (Node.js) authoritative server + SQLite — see "Base project" below.
- **Team size**: 3–10 people
- **Status**: Playable — full RPG systems already working (movement, inventory/equipment, abilities, leveling, quests, vendors, trainers, chat) via the base project below. Reskinning into the creature-taming design (capture mechanic, Emergents/species, Shards) is the current phase of work.

## Base project

This codebase is forked from **[t5c (The 5th Continent)](https://github.com/orion3dgames/t5c)** by Orion3d — an MIT-licensed, open-source multiplayer 3D RPG built on Babylon.js and Colyseus. It's used as the engineering foundation (networking, movement, inventory, combat, quests, persistence) so effort goes into the creature-taming systems and content instead of re-building an MMO engine from scratch. See `LICENSE` (MIT, original copyright retained) and credit t5c/Orion3d in any public build's credits screen.

Original t5c README content (features, links, credits) is preserved in [`docs/T5C_ORIGINAL_README.md`](docs/T5C_ORIGINAL_README.md).

## Running it locally

```
npm install
npm run server-dev   # terminal 1 — server at http://localhost:3000 (Colyseus monitor at /monitor)
npm run client-dev    # terminal 2 — client at http://localhost:8080
```

Requires Node.js LTS. Uses SQLite by default (`database.db`, auto-created); MySQL is supported via `src/shared/Config.ts` if preferred. **Open the client at `http://localhost:8080` specifically (not `127.0.0.1`)** — the client's dev-mode check for whether to talk to a local server is a literal string match on `localhost:8080`.

## Legal note

This project does not use, reference, decompile, or derive from any proprietary MMO client/server (including Digimon Masters Online or similar). Only the genre conventions of monster-taming MMORPGs are used, which are not protected by copyright. The engineering base (t5c) is a permissively-licensed (MIT) open-source project, credited above. All creature designs, names, lore, and game-specific code in this repo are original or sourced from permissively-licensed open source projects — see `art/creatures/` and `art/environments/` for per-asset attribution.
