# Environments — art sources

## Sourced and in-repo already

- **KayKit: Dungeon Remastered** (`kaykit-dungeon-remastered/`) — 200+ stylized dungeon props/environment pieces by Kay Lousberg, CC0. Downloaded directly from the official GitHub mirror. Good base for dungeon instances and possibly the Origin hub's interior. See that folder's `ATTRIBUTION.md`.

## Still to source

1. **KayKit — Character Animations**
   - 161 humanoid animations, intended for the player character (not creatures)
   - License: CC0
   - Not yet found on a GitHub mirror — try https://kaylousberg.itch.io/kaykit-character-animations if downloading directly, or check the KayKit-Game-Assets GitHub org for a mirror

## Folder convention going forward

```
art/environments/<pack-name>/     raw sourced pack, unmodified
art/environments/shards/<name>/   our own zone compositions built from the packs
```

Keep `<pack-name>/` folders pristine (unmodified) so we can re-download/update cleanly. Zone/level composition work happens by referencing these assets from game code/data, not by editing the source packs.
