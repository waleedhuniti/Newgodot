# Creature MMO (working title)

An original creature-collecting MMORPG: capture wild creatures, raise and evolve them, build a team, and battle other players — built entirely with original IP (no Digimon/Pokémon assets, names, or code).

- **Design doc**: [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md)
- **World lore**: [`docs/WORLD_LORE.md`](docs/WORLD_LORE.md)
- **Main story**: [`docs/STORY.md`](docs/STORY.md)
- **Act 1 full questline**: [`docs/QUESTLINE_ACT1.md`](docs/QUESTLINE_ACT1.md)
- **Tech plan**: [`docs/TECHNICAL_PLAN.md`](docs/TECHNICAL_PLAN.md)
- **Stack**: Node.js + TypeScript — Express/Prisma/Postgres backend API, Colyseus realtime game server, Three.js + Vite web client. No Unity (see tech plan §1 for why).
- **Team size**: 3–10 people
- **Status**: Playable end-to-end with placeholder art — login, character creation with a starter creature, and live multiplayer movement all verified working in a real browser (see tech plan §2). No real map/monster models, capture mechanic, or combat yet.

## Running it locally

```
npm install                        # from repo root — npm workspaces
cd backend && cp .env.example .env # configure DATABASE_URL / JWT_SECRET
npx prisma migrate dev
npx prisma db seed
cd ..
npm run dev:backend                # terminal 1
JWT_SECRET=<same as backend .env> npm run dev:realtime   # terminal 2
npm run dev:client                 # terminal 3, then open the printed localhost URL
```

Requires a locally running Postgres and (for future Redis-backed features) Redis. See `backend/README.md`, `realtime/README.md`, and `client/README.md` for details.

## Legal note

This project does not use, reference, decompile, or derive from any proprietary MMO client/server (including Digimon Masters Online or similar). Only the genre conventions of monster-taming MMORPGs are used, which are not protected by copyright. All creature designs, names, lore, and code in this repo are original or sourced from permissively-licensed open source projects.
