# Creatures — art sources

## Sourced and in-repo already

- **Duskwyrm** (`sources/oscar-creativo-dragon/`) — "Dragon Character 3d" by Oscar Creativo, CC-BY licensed (confirmed with the author), pre-rigged. See `species/duskwyrm.md` for how it maps to the game's creature system, and that folder's `ATTRIBUTION.md` for the required credit text.
- **Animated Monster Pack** (`quaternius-animated-monster-pack/`) — Bat, Skeleton, Dragon, Slime by Quaternius, CC0. Converted to glTF (`client/public/models/*.glb`, all animation clips preserved) and **live in the web client right now** as wild-creature placeholders. See that folder's `ATTRIBUTION.md`.

## Still to download (more packs, same style)

I can't download these directly (this session's network policy blocks general asset sites). Please download the zips below and extract them into this folder, each in its own subfolder as named. Then let me know and I'll wire them into the client and map species to the evolution lines in `docs/GAME_DESIGN.md`.

1. **Quaternius — Ultimate Monsters Pack** → extract into `art/creatures/quaternius-ultimate-monsters/`
   - https://quaternius.com/packs/animatedmonster.html (or the Sketchfab/poly.pizza mirror)
   - 50 monsters, rigged with attack/death/run/walk animations. Formats: .blend/.fbx/.obj/.gltf
   - License: CC0 (free for any use, no attribution required)
   - This is the bigger 50-creature pack — what we have in-repo now is the smaller 4-creature "Animated Monster Pack", same artist/style

2. **Quaternius — Cute Animated Monsters Pack** → extract into `art/creatures/quaternius-cute-monsters/`
   - https://quaternius.com/packs/cutemonsters.html
   - 21 more stylized creatures, same CC0 license

3. **Quaternius — Ultimate Animated Animals Pack** → extract into `art/creatures/quaternius-animals/`
   - https://quaternius.com/packs/ultimateanimatedanimals.html
   - Real-world-animal-styled creatures, good for early-tier/pre-evolution forms
   - License: CC0

4. **Meshtint — Fantasy Enemy Pack** → extract into `art/creatures/meshtint-fantasy-enemy/`
   - https://www.meshtint.com/products/fantasy-enemy-pack-01
   - 8 rigged/animated fantasy monsters (orc, mushroom monster, magma demon, etc.) with idle/attack/walk
   - Check the license terms on the page before commercial use — confirm free tier terms

5. **Meshtint — Forest Creatures Pack** → extract into `art/creatures/meshtint-forest-creatures/`
   - https://www.meshtint.com/products/forest-creatures-pack
   - Richer animation set (bite/claw/breath attack, spell cast, hit, die)
   - Check whether this specific pack is free or paid before relying on it

## Folder convention going forward

```
art/creatures/<pack-name>/          raw downloaded pack, unmodified
art/creatures/species/<name>/       our own mapping: which pack model = which original species
```

Do not rename or modify files inside a `<pack-name>/` folder — keep raw packs pristine so we can re-download/update cleanly. Species-to-model mapping happens in the `species/` folder or in a data file, not by editing the source packs.
