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
- **Project root**: repo root (`project.godot` there). `art/` is untouched by
  the engine; `scenes/` and `scripts/` hold the game itself. `docs/` holds
  design/technical docs *and* the hosted HTML5 build (see §6) side by side -
  GitHub Pages only supports repo-root or `/docs` as a source, so the build
  output lives there rather than disturbing existing doc links.
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
  `Running_A_Rig` - `Skeleton_Warrior.glb` is a placeholder player model, see §8).
- Environment: `assets/environments/dungeon_01/dungeon_01.glb`, the same
  KayKit-built dungeon hall from the t5c era (copied over, not rebuilt - see
  `art/environments/shards/dungeon_01/build.py` if it needs regenerating).
  Collision is currently a single flat `StaticBody`/`BoxShape` floor sized to
  match the hall, not real per-wall collision (see §8).
- `scripts/AnimatedCharacter.gd` — shared `KinematicBody` base for
  Player/Enemy: finds the `AnimationPlayer` buried inside a KayKit model,
  `play_anim()` (no-ops if already playing unless forced), `health`/
  `max_health`/`is_dead`, `take_damage()`/`die()` with `died`/`health_changed`
  signals.
- Combat: click an enemy to target it (raycast, checks `is_in_group("enemies")`),
  auto-attack in range on a cooldown, skill on key `1` (shorter range, more
  damage, longer cooldown). Both use the KayKit model's own attack animations.
- `scenes/Enemy.tscn` / `scripts/Enemy.gd` — a simple melee mob
  (`Skeleton_Minion.glb`): idle until the player enters aggro range, walks
  into attack range, then attacks on cooldown; despawns a few seconds after
  death. One instance placed in `Main.tscn` near the player's spawn point.
- Headless combat verification: `scripts/Main.gd` supports `--test-combat`
  (auto-targets the nearest enemy for the player instead of requiring a mouse
  click, and logs both sides' HP every 30 frames), since a single screenshot
  can't show a fight resolving over time. Combined with `--screenshot`, this
  caught a real bug: `signal health_changed(current, max)` failed to parse
  because `max` is a reserved GDScript built-in, not a valid signal parameter
  name (fixed by renaming to `max_hp`).
- `addons/wyvernbox/` / `addons/wyvernbox_prefabs/` — the "Wyvernbox"
  inventory addon (MIT, vendored wholesale - see
  `docs/THIRD_PARTY_LICENSES/wyvernbox-LICENSE.md`), provided to this project
  by its owner. Only the core data model is used - `ItemType` (a Resource
  defining a kind of item), `ItemStack` (count + type), and `Inventory`
  (stacking, capacity, save/load, `count_all_items()`). Its click/2D-UI-
  oriented ground-item-view, tooltip, and crafting systems aren't wired up -
  they don't fit this game's WASD/mouse-look-captured controls, so our own
  simpler walk-over `Pickup.gd` (below) is used instead for now.
  `resources/item_types/ItemType_Coin.tres`/`ItemType_Key.tres` are the two
  item types defined so far.
- `scripts/Pickup.gd` — a spinning `Area` that grants an item to whatever
  enters it (checks `has_method("add_item")`) and frees itself.
  `scenes/CoinPickup.tscn`/`scenes/KeyPickup.tscn` wrap it with the KayKit
  dungeon pack's `coin.gltf.glb`/`key.gltf.glb` models. `Player.gd` owns an
  `Inventory` (`inventory.try_add_item(ItemStack.new(item_type, amount))`
  via `add_item()`).
- `scenes/HUD.tscn`/`scripts/HUD.gd` — a `CanvasLayer` label reading
  `inventory.count_all_items()` off the `Inventory`'s `item_stack_*` signals
  and rendering *every* item type present generically (`"<Name> x<count>"`,
  comma-separated) rather than hardcoding specific items - this is the
  player's whole "inventory screen" for now, no separate menu. Also a
  `ProgressBar` reading the player's `health_changed` signal, and a "Click to
  play"/controls overlay (see §6).
- `scenes/Chest.tscn`/`scripts/Chest.gd` — an `Area`-based interactable
  (`chest_gold.glb`, which conveniently ships its lid as a separate child
  mesh with its origin already at the hinge, so opening it is just rotating
  that one node). Walk into range, press `E`: if the player's inventory has
  the required item type (a key), `Inventory.consume_items({type: 1})` spends
  one and the chest grants a reward item (a sword) via the player's
  `add_item()`. One placed in `Main.tscn`.
- `scripts/Fireball.gd`/`scenes/Fireball.tscn`/`scenes/FireballBurst.tscn` -
  the player's skill (key `1`) now casts a homing fireball projectile instead
  of dealing instant melee damage; see §7 for where this came from and what
  changed porting it.
- `scenes/DamageNumber.tscn`/`scripts/DamageNumber.gd` — a floating "-N" that
  rises and fades over ~0.8s wherever a character takes damage
  (`AnimatedCharacter.gd`'s `take_damage()` spawns one for both Player and
  Enemy). Godot 3.x has no Label3D/billboard text, so it's a 2D `Label` on
  its own `CanvasLayer` whose screen position is recomputed from a stored 3D
  world point via `Camera.unproject_position()` every frame instead.
- Loot: `Enemy.gd`'s `die()` spawns a `CoinPickup` at its death position
  (`loot_scene`, currently always a coin - no drop table yet).
- Headless pickup verification: `--test-pickup` teleports the player onto
  each standalone pickup in turn (skipping the walk there) and logs
  inventory after each; confirmed both the coin and key pickups grant the
  right item and despawn. `--test-combat`'s per-30-frame log now also
  counts pickups in the world, confirming the enemy's coin drop appears
  exactly when it dies.
- Two real bugs found integrating Wyvernbox, both specific to Godot 3.x
  (the addon itself is correct Godot 3.x code, these are compatibility traps
  rather than upstream mistakes):
  - Godot 3.x's editor never wrote `_global_script_classes` into
    `project.godot` from a plain `godot3 --editor --quit` pass (unlike our
    own scripts, which happened to get picked up before) - every
    `class_name`-declared identifier across all 24 Wyvernbox scripts came
    back "isn't declared in the current scope". Fixed by generating that
    block ourselves from a scan of every `class_name` declaration in the
    project rather than relying on the editor to write it.
  - `Inventory.new()` left `_cells` empty (so every `try_add_item()` silently
    failed) because Godot 3.x doesn't invoke a `setget` setter for a
    property's initial declared default (`export var width := 8 setget
    _set_width`) - only for an explicit assignment after construction. Fixed
    by assigning `inventory.width = 20` in `Player.gd`'s `_ready()` to force
    the setter to actually run.

Not yet built: quests, creature-taming, a real drop table - everything
beyond character movement, basic melee combat, and simple item pickup is
new work, same as it would be starting from nothing, except now on an
engine that isn't fighting us.

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

## 6. Hosting: HTML5 export via GitHub Pages

Contrary to §5 - `godotengine.org`/`tuxfamily.org` (Godot's own download/docs
domains) are blocked, but **`github.com`'s release-asset CDN is not** - so
Godot 3.5.2's official export templates (a GitHub release asset on
`godotengine/godot`) download fine even though the same file from Godot's own
site wouldn't. This is what makes exporting - and therefore hosting - possible
at all from this sandbox. Worth re-testing if a future session needs something
else assumed blocked; not every "official Godot" URL behaves the same.

- **Export templates**: `godot3`'s apt package ships the editor, not export
  templates - those install separately to
  `~/.local/share/godot/templates/3.5.2.stable/`, unzipped from
  `Godot_v3.5.2-stable_export_templates.tpz` off GitHub releases.
- **`export_presets.cfg`** (committed, not gitignored - it's needed to
  reproduce the build): one HTML5 preset, `variant/thread_support=false`.
  Threaded WASM needs `Cross-Origin-Opener-Policy`/`Cross-Origin-Embedder-Policy`
  response headers that GitHub Pages doesn't set, so non-threaded is the only
  variant that actually runs there.
- **Texture size problem and fix**: a first export attempt produced a 389MB
  `.pck` - almost entirely `dungeon_01.glb`'s 60 extracted materials, each
  embedding an *uncompressed* 1024x1024 RGBA texture (~4MB apiece, ~250MB
  total). Godot 3.x's glTF scene importer has no compression option for
  textures extracted this way (unlike standalone texture files, which the
  "VRAM Texture Compression" export option does cover) - so `export_filter`
  exclusions alone couldn't fix this without losing the dungeon's materials
  entirely (tried first; confirmed via a headless-Chromium screenshot that it
  renders geometry correctly but flat white, no textures - see below).
  Fixed with `tools/optimize_dungeon_textures.gd`, a one-time post-import
  script that downscales each material's texture to 256x256 (plenty for this
  stylized low-poly pack) via `Image.resize()` + `ResourceSaver.save()`,
  cutting that folder from ~250MB to ~17MB. Also excluded unused fbx/obj
  source variants and sample folders never referenced by any scene
  (`art/creatures/kaykit-skeletons/Characters/fbx/`, `.../Samples/`,
  `.../Assets/`, the dungeon pack's `fbx/`/`obj/` folders, unused creature
  source/animation packs) via `export_filter`'s `exclude_filter`. Final
  build: ~59MB `.pck` + ~14MB `.wasm` + a few small files, comfortably under
  GitHub's 100MB-per-file hard limit.
- **Verifying a web export headlessly**: a screenshot inside the Godot editor
  proves the *native* build renders; it says nothing about the *HTML5* build,
  which runs a completely different code path (Emscripten/WebAssembly, WebGL
  instead of GLES3 directly). Verified instead with Chromium (pre-installed,
  `/opt/pw-browsers/chromium`) via Playwright, loading the build off a plain
  `python3 -m http.server` and screenshotting after a load delay - this is
  what actually caught the missing-textures problem above, and confirmed the
  fix.
- **Rebuilding after a fresh import**: `.material` files are gitignored
  import-cache output (regenerated from `dungeon_01.glb`, not source content),
  so a fresh clone's re-import produces full-size ones again. Run
  `godot3 --path . -s tools/optimize_dungeon_textures.gd` after importing and
  before exporting, or the web build balloons back to ~95MB+.
- **Rebuilding the site**: after changing the game,
  `godot3 --path . --export "HTML5" build/web/index.html` (into the gitignored
  `build/` scratch dir), verify it, then copy `build/web/*` into `docs/` and
  commit. GitHub Pages serves whatever's on `docs/` on this branch directly -
  no build step runs on GitHub's side.
- **Browsers block silent Pointer Lock**: `Player.gd` originally called
  `Input.set_mouse_mode(MOUSE_MODE_CAPTURED)` in `_ready()`, which works fine
  in the native build but does nothing in a browser - Pointer Lock requires an
  actual user gesture (click/keypress), not a request fired from page-load
  code, so camera look silently never engaged. Fixed by moving the capture
  call into the first left-click's `_unhandled_input` handler instead, and
  added a "Click to play" overlay (`HUD.tscn`'s `Tutorial` node, toggled by
  `Input.get_mouse_mode()`) so it's obvious why nothing responds until then.
  Caught by the user actually trying to play the hosted build - a headless
  screenshot alone wouldn't show this, since it never simulates a click.
  Confirmed the original bug is gone (page-load no longer errors requesting
  Pointer Lock), but **could not fully verify the fix's happy path**
  headlessly: Chromium's automation layer (Playwright/CDP) doesn't treat a
  synthetic `page.mouse.click()` as a "trusted" user gesture for this
  specific API, so `document.pointerLockElement` stays `none` even after
  clicking in the test harness - a known limitation of browser automation for
  Pointer-Lock/Fullscreen-style APIs, not something specific to Godot. The
  Pointer Lock spec only requires an actual click, which a real user
  provides, so the fix should work in practice; still needs a real human
  click to fully confirm.
- **The tutorial overlay itself ate the click meant to dismiss it**: found by
  an actual user, not headlessly - a real click still didn't dismiss the
  overlay or capture the mouse. Root cause: `Control`-derived nodes default
  to `mouse_filter = 0` (Stop), which absorbs a click before it ever reaches
  `_unhandled_input` - so every click landed on the full-screen overlay and
  never reached `Player.gd`'s capture-on-click handler. Fixed by setting
  `mouse_filter = 2` (Ignore) on the overlay's `Control`, `ColorRect`, and
  `Label`. Confirmed via a headless-Chromium click test that the overlay
  actually disappears afterward now.

## 7. Porting the fireball VFX from Godot 4

The player's skill (key `1`) casts a fireball, using a small Godot 4 VFX
asset provided to this project (two overlapping noise-shaded spheres for a
molten-core look, plus particle trails) as the starting point. Godot 4 assets
don't load in this Godot 3.5 project (see §2/§6 for why we're on 3.5 at all),
so this was a hand port, not a drop-in.

- **What ported directly**: the `.gdshader` files almost verbatim - Godot
  3.x and 4.x's spatial shading language is close to identical for basic
  vertex/fragment work (`VERTEX`, `NORMAL`, `UV`, `TIME`, `ALBEDO`, `ALPHA`
  all match). Two mechanical renames needed: `hint_color` instead of Godot
  4's `source_color` uniform hint, and `depth_draw_alpha_prepass` instead of
  4's `depth_prepass_alpha` render mode (the latter only surfaced as a
  `SHADER ERROR: Invalid render mode` at runtime - worth remembering for any
  future shader port, since it's an easy one to miss by inspection).
- **What didn't port**: the two custom `.res` `ArrayMesh` files (a trail
  strip and a particle billboard) are Godot 4's binary resource format and
  won't load in 3.x - substituted plain `QuadMesh` primitives instead, which
  the shaders don't care about (they just need *a* mesh to shade). The scene
  files themselves (`Node3D`/`MeshInstance3D`/`GPUParticles3D`/`Transform3D`,
  format 3) also don't load - hand-rewritten as Godot 3.x's
  `Spatial`/`MeshInstance`/`Particles`/`Transform` (format 2), and
  `NoiseTexture2D`+`FastNoiseLite` (Godot 4) became `NoiseTexture`+
  `OpenSimplexNoise` (Godot 3.x's older but equivalent noise texture pair).
- **`ParticlesMaterial` property names differ** from Godot 4's
  `ParticleProcessMaterial`: no `_min`/`_max` suffix split - Godot 3.x just
  has `initial_velocity`/`initial_velocity_random` and `scale`/`scale_random`
  instead of `initial_velocity_min`/`initial_velocity_max` and
  `scale_min`/`scale_max`. Verified the exact property names via
  `ParticlesMaterial.new().get_property_list()` rather than guessing, given
  how often small Godot-version property renames like this one have bitten
  this project already.
- **A real projectile bug, not a porting issue**: the fireball originally
  oriented toward the target once at spawn (`look_at()` in `_ready()`) and
  then flew a fixed straight line. Since the target (an `Enemy`) is usually
  still walking, a fixed heading and a moving target reliably diverge before
  ever meeting - the fireball just silently expired after its lifetime with
  no hit ever registering, confirmed via `--test-fireball`'s per-frame HP log
  showing only melee-auto-attack damage (multiples of 6), never the
  fireball's 14. Fixed by re-running `look_at()` every physics frame (a
  homing missile) rather than once at spawn - also just better feel for a
  click-to-target combat system where the player isn't manually leading shots.
- **Headless verification**: `--test-fireball` (`Main.gd`) sets the player's
  target to the nearest enemy and calls `_try_use_skill()` directly, logging
  HP the same way `--test-combat` does. Confirmed via a debug-cam screenshot
  that the fireball renders and travels correctly, and via the HP log that it
  now actually connects for its full 14 damage.

## 8. Known gaps / next steps

1. **Placeholder player model**: using `Skeleton_Warrior.glb` (from
   `art/creatures/kaykit-skeletons/`, meant for enemies) as a stand-in player
   character. Needs a real "Anchor" model.
2. **Collision is floor-only**: the dungeon's walls/pillars/props have no
   collision yet, just the flat floor plane in `Main.tscn`. Fine for a first
   milestone, will let the player walk through walls until addressed - either
   hand-authored collision shapes per piece, or Godot's mesh-to-trimesh-collision
   import option (needs the editor's per-file import settings, not something
   hand-authored `.tscn` text easily expresses).
3. **No quests/creature-taming yet** - combat, a first enemy, basic item
   pickup, and one chest/reward interaction are done (§4), but nothing past
   that.
4. **Inventory has a HUD readout, not a screen**: shows every item and count
   live, but there's no menu, no item use/equip beyond the one chest
   interaction, no drag-and-drop.
5. **Only one enemy type, one drop**: `Skeleton_Minion` is the only mob and
   it always drops exactly one coin - no drop table/chance/variety yet.
   Likewise only one chest, always the same key/sword pairing.
6. **The sword reward doesn't do anything yet**: picking it up just adds it
   to the inventory count - no equip system, no stat change.
7. **No multiplayer** - out of scope for now (§1).
