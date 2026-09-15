# Environments — placeholder art sources

Same situation as `art/creatures/` — download these and extract into this folder, then let me know so I can wire them into the Unity project's Shard/zone scenes.

## To download

1. **KayKit — Dungeon Pack (Remastered)** → extract into `art/environments/kaykit-dungeon/`
   - https://kaylousberg.itch.io/kaykit-dungeon-remastered (or the original `kaykit-dungeon-pack`)
   - 200+ stylized dungeon props/environment pieces
   - License: CC0, free for personal and commercial use, no attribution required
   - Good base for our dungeon instances and possibly the hub city interior

2. **KayKit — Character Animations** → extract into `art/environments/kaykit-animations/`
   - https://kaylousberg.itch.io/kaykit-character-animations
   - 161 humanoid animations, intended for the player character (not creatures)
   - License: CC0

## Folder convention going forward

```
art/environments/<pack-name>/     raw downloaded pack, unmodified
art/environments/shards/<name>/   our own zone compositions built from the packs
```

Keep `<pack-name>/` folders pristine (unmodified) so we can re-download/update cleanly. Zone/level composition work happens in Unity scenes referencing these assets, not by editing the source packs.
