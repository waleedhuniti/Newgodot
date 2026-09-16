# Creature MMO (working title)

An original creature-collecting game: capture wild creatures, raise and evolve them, build a team, and battle other players — built entirely with original IP (no Digimon/Pokémon assets, names, or code).

- **Design doc**: [`docs/GAME_DESIGN.md`](docs/GAME_DESIGN.md)
- **World lore**: [`docs/WORLD_LORE.md`](docs/WORLD_LORE.md)
- **Main story**: [`docs/STORY.md`](docs/STORY.md)
- **Act 1 full questline**: [`docs/QUESTLINE_ACT1.md`](docs/QUESTLINE_ACT1.md)
- **Tech plan**: [`docs/TECHNICAL_PLAN.md`](docs/TECHNICAL_PLAN.md)
- **Stack**: Godot 3.5.2 (GDScript), single-player for now — see `docs/TECHNICAL_PLAN.md` §1 for why.
- **Status**: Early — a working 3D player character (movement, camera, animation) in a real built environment. Everything past that (combat, inventory, quests, creatures) is new work in progress. An earlier iteration (Babylon.js/Colyseus, forked from t5c) is archived in `archive/t5c-base/` — see its `README.md` for why it was retired.

## Running it locally

Requires Godot 3.5 (`godot3`/`godot3-server` on Debian/Ubuntu via apt).

```
godot3 --path . --editor --quit   # first run only: imports all assets, can take a while
godot3 --path .                   # play it
```

For headless verification (no display needed, e.g. in CI or a sandbox), see
`docs/TECHNICAL_PLAN.md` §3 for the `--screenshot`/`--frames`/`--auto-quit` flags
`scripts/Main.gd` supports.

Controls: WASD to move, mouse to look (Esc to release the cursor), Shift to run, Space to jump.

## Legal note

This project does not use, reference, decompile, or derive from any proprietary MMO client/server (including Digimon Masters Online or similar). Only the genre conventions of monster-taming games are used, which are not protected by copyright. All creature designs, names, lore, and game-specific code in this repo are original or sourced from permissively-licensed open source projects — see `art/creatures/` and `art/environments/` for per-asset attribution. The archived `archive/t5c-base/` code remains under its own MIT license (see `archive/t5c-base/LICENSE`) and is no longer part of the running game.
