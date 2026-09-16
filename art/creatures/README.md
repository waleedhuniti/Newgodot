# Creatures — art sources

## Sourced and in-repo already

- **Duskwyrm** (`sources/oscar-creativo-dragon/`) — "Dragon Character 3d" by Oscar Creativo, CC-BY licensed (confirmed with the author), pre-rigged. See `species/duskwyrm.md` for how it maps to the game's creature system, and that folder's `ATTRIBUTION.md` for the required credit text.
- **Animated Monster Pack** (`quaternius-animated-monster-pack/`) — Bat, Skeleton, Dragon, Slime by Quaternius, CC0. (The glTF conversion made for the earlier Three.js client is gone now that the project moved to the t5c/Babylon.js base — needs reconversion into that pipeline's expected format, likely VAT per `docs/TECHNICAL_PLAN.md` §4.6, before it's usable again.)
- **KayKit: Skeletons Character Pack** (`kaykit-skeletons/`) — 4 rigged skeleton characters (Minion, Mage, Rogue, Warrior) by Kay Lousberg, CC0. Downloaded directly from the official GitHub mirror. See that folder's `ATTRIBUTION.md`.

## Still to source

Direct downloads from asset sites (quaternius.com, itch.io, Sketchfab, etc.) aren't reachable from this session's network — but **GitHub-hosted mirrors work fine** (that's how the KayKit packs above were sourced, via the official `KayKit-Game-Assets` GitHub org). Check for a GitHub mirror before assuming a pack needs manual upload.

1. **Quaternius — Ultimate Monsters Pack** → `art/creatures/quaternius-ultimate-monsters/`
   - 50 monsters, rigged with attack/death/run/walk animations. Formats: .blend/.fbx/.obj/.gltf. License: CC0.
   - This is the bigger 50-creature pack — what we have in-repo now is the smaller 4-creature "Animated Monster Pack", same artist/style. No GitHub mirror found yet — worth checking again or uploading directly if a small enough subset is picked.

2. **Quaternius — Cute Animated Monsters Pack** / **Ultimate Animated Animals Pack** — same situation, CC0, no GitHub mirror found yet.

3. **Meshtint — Fantasy Enemy Pack / Forest Creatures Pack** — license terms need confirming regardless of source; lower priority than the confirmed-CC0 options above.

## Folder convention going forward

```
art/creatures/<pack-name>/          raw sourced pack, unmodified
art/creatures/species/<name>/       our own mapping: which pack model = which original species
```

Do not rename or modify files inside a `<pack-name>/` folder — keep raw packs pristine so we can re-source/update cleanly. Species-to-model mapping happens in the `species/` folder or in a data file, not by editing the source packs.
