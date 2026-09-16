# Technical Plan — Creature MMO

## 1. Stack (current — Godot 3.5, single-player)

The engine is **Godot 3.5.2** (GDScript), built fresh rather than inherited. This
replaces the project's second technical iteration - a fork of
**[t5c](https://github.com/orion3dgames/t5c)** (Babylon.js + Colyseus) - which is
archived in `archive/t5c-base/` (see that folder's `README.md` for why it was
retired: real recurring bugs, a small-hobby-project maintenance ceiling, and a
dated look that reskinning wasn't fixing).

This iteration also drops multiplayer/MMO scope for now, in favor of getting a
single, solid, well-verified 3D game working first. Design docs still describe
the eventual MMO vision; treat the multiplayer parts of them as future work, not
current scope.

- **Engine**: Godot 3.5.2 (`godot3` / `godot3-server` packages, installed via apt
  in this sandbox — Godot 4's official downloads are blocked by this sandbox's
  network policy, so 3.5 is what's actually available here).
- **Language**: GDScript.
- **Project root**: repo root (`project.godot` there). `docs/` and `art/` are
  untouched by the engine; `scenes/` and `scripts/` hold the game itself.
- **Rendering**: GLES3.

## 2. Why Godot 3.5 and not 4

Godot 4 is where active development happens (3.x is maintenance-only), but its
official builds come from domains this sandbox's egress policy blocks, the same
way it blocks Railway and tunnel services (see §5). 3.5 is a full, real engine
available right now via `apt install godot3 godot3-server` - not a downgrade
chosen for convenience, a downgrade forced by what's actually reachable here.
If a future session has broader network access, re-evaluate moving to 4.

## 3. Headless verification workflow

Godot's editor (and exported games) can run fully headless under Xvfb, including
real GPU-style rendering (via `llvmpipe` software rasterization) and screenshot
capture - this is how every visual claim in this project's history gets checked,
rather than just trusting the code compiles:

```
xvfb-run -a --server-args="-screen 0 1280x800x24" godot3 --path . \
  --screenshot=/tmp/out.png --frames=30 --quit
```

`--screenshot`/`--frames`/`--quit` are our own convention (`scripts/Main.gd`
reads them from `OS.get_cmdline_args()`), not built into Godot - add the same
pattern to any new top-level scene that needs headless verification.

**First-run import is slow.** Before any script/scene referencing a `res://`
asset can load, Godot needs an initial import pass, and running a scene
directly (`--screenshot=...`) errors with "Make sure resources have been
imported by opening the project in the editor at least once" if that hasn't
happened yet. Trigger it once per fresh clone (or whenever many new binary
assets are added at once) with:

```
xvfb-run -a --server-args="-screen 0 1280x800x24" godot3 --path . --editor --quit
```

This scans and imports *everything* under the project root that looks
importable - in this repo, that includes the full `art/` tree (KayKit packs,
Quaternius pack, etc.), not just what a scene currently references - so budget
real time for it (it took on the order of 15-20+ minutes the first time, all
CPU-bound software-rendering import work, no network involved). It only needs
to happen again when assets are added/changed; the resulting `.import/` cache
(gitignored) makes subsequent runs fast.

## 4. What's built so far

- `scenes/Main.tscn` — the one scene: the dungeon environment + a player.
- `scenes/Player.tscn` / `scripts/Player.gd` — third-person `KinematicBody`.
  Mouse-look camera (captured by default, Esc toggles), WASD relative to camera
  yaw, Shift to run, Space to jump, gravity, and animation state driven by a
  `KayKit` character's baked-in `AnimationPlayer` (`Idle_Rig`/`Walking_A_Rig`/
  `Running_A_Rig` - `Skeleton_Warrior.glb` is a placeholder player model, see §6).
- Environment: `assets/environments/dungeon_01/dungeon_01.glb`, the same
  KayKit-built dungeon hall from the t5c era (copied over, not rebuilt - see
  `art/environments/shards/dungeon_01/build.py` if it needs regenerating).
  Collision is currently a single flat `StaticBody`/`BoxShape` floor sized to
  match the hall, not real per-wall collision (see §6).

Not yet built: combat, enemies, inventory, quests - everything beyond "walk
around a 3D space" is new work, same as it would be starting from nothing,
except now on an engine that isn't fighting us.

## 5. Hosting / network constraints in this sandbox

This sandbox's network egress policy blocks most third-party services outright
(confirmed for: Cloudflare quick tunnels, Railway's API, Tripo3D's API/site,
`google.com`). It does *not* block `github.com`'s raw file CDN
(`raw.githubusercontent.com`) for individual files, but it does block
`git clone`/the GitHub API/`codeload.github.com` for any repo not already
attached to this Claude Code session, and a session can only have repos from
one GitHub owner attached at a time (`add_repo` refuses cross-owner adds) - so
pulling in another org's full repo isn't possible from here even via git.
Godot's own download servers are blocked the same way (§2). Assume any new
third-party API/service needs a live check before depending on it, and that
"download this open-source project's source" is not reliably possible from
this sandbox unless it's small enough to fetch file-by-file via raw content
URLs.

## 6. Known gaps / next steps

1. **Placeholder player model**: using `Skeleton_Warrior.glb` (from
   `art/creatures/kaykit-skeletons/`, meant for enemies) as a stand-in player
   character. Needs a real "Anchor" model.
2. **Collision is floor-only**: the dungeon's walls/pillars/props have no
   collision yet, just the flat floor plane in `Main.tscn`. Fine for a first
   milestone, will let the player walk through walls until addressed - either
   hand-authored collision shapes per piece, or Godot's mesh-to-trimesh-collision
   import option (needs the editor's per-file import settings, not something
   hand-authored `.tscn` text easily expresses).
3. **No combat/enemies/inventory/quests yet** - see §4.
4. **No multiplayer** - out of scope for now (§1).
