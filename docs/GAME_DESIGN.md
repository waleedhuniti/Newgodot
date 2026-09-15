# Game Design Document — Creature MMO (working title)

## 1. High concept

A third-person online MMORPG where players explore a persistent world, **capture wild creatures**, raise and **evolve** them through tiers, and build a team to battle other creatures and other players. The feel is: tactical real-time-ish combat, a satisfying long-term collection/evolution loop, and social hub towns between hunting zones.

This is an **original IP**. No character designs, creature names, lore, or code are taken from any existing commercial monster-taming game. Only broad genre conventions (which are not copyrightable) are reused: capture mechanics, tiered evolution, team-based battling, PvE zones + PvP arenas, guild/social systems.

## 2. Pillars

1. **Collect & grow** — every creature has a multi-stage evolution path; players form emotional attachment to a starter and build toward specific end-tier forms.
2. **Readable, fast combat** — real-time active combat (not turn-based), with a small hotbar of creature abilities, dodge/positioning, and elemental-type matchups.
3. **A world worth traveling** — persistent shared zones, world bosses, and social hub cities where trading/guild activity happens.
4. **Fair progression** — no pay-to-win; monetization is cosmetic + convenience only (see §8).

## 3. World & setting

Full background/story bible: [`docs/WORLD_LORE.md`](WORLD_LORE.md). Summary:

- **Setting**: a parallel data-dimension called **the Continuum**, fractured into regions called **Shards**, connected by portals. Each Shard congealed around a "flavor" of data (records, creative streams, comms, waste heat, etc.), giving it a distinct biome/element (forest, volcanic, tundra, ruins, etc.) and native creature population — in-fiction, creatures are called **Emergents**; players are **Anchors**.
- **Hub city**: **Origin**, the one Shard Anchors built themselves — bank, marketplace/auction house, guild hall, the **Resequencing Spire** (evolution altar), portal terminal.
- **Zones**: each Shard has open-world PvE areas (wild creature spawns, gathering nodes, mini-bosses) and one or more instanced dungeons.
- **World bosses**: scheduled, server-wide **Null Surge** spawns requiring multiple players/parties to defeat, dropping rare evolution catalysts. "The Null" is the setting's antagonist force — corrupted/unstable data-lifeforms — and the source of PvE hostiles generally.

UI/gameplay copy can use plain terms (creature, evolve, zone) where clarity matters more than flavor; the lore terms above are for quest text, NPC dialogue, and narrative moments.

## 4. Creature system

### 4.1 Species & typing
- Creatures belong to one of 8 elemental types (Flame, Tide, Verdant, Stone, Gale, Volt, Shade, Radiant) with a simple strength/weakness wheel (each type strong vs. 2, weak vs. 2, neutral vs. rest) — easy to learn, deep enough for team-building.
- Each species has a base line + 2–3 evolution stages (Tier 1 → Tier 2 → Tier 3), each with distinct model, stat growth, and unlocked ability.

### 4.2 Capture
- Wild creatures spawn in the open world with a visible "capture difficulty" (based on level/rarity).
- Capture is skill-based: weaken the creature in combat, then a short timing/QTE-based capture action (not a flat random-chance throw) — keeps it interactive rather than a slot-machine mechanic.
- Captured creatures go into a player's roster (active team of 3–4 + storage box).

### 4.3 Evolution
- Evolution requires: minimum level/bond reached + an evolution catalyst item (dropped by dungeons/world bosses or crafted) + returning to an Evolution Altar in a hub.
- Some species have **branching evolutions** (same Tier 1 can evolve into one of 2 Tier 2 forms depending on which stat/bond path was invested in) — adds build diversity and trading value to rare branches.

### 4.4 Bond & stats
- Each creature has core stats (HP, Attack, Defense, Speed, Focus) that grow with level and can be lightly customized via training items (soft respec allowed — no permanently "wasted" creatures).
- A "Bond" meter increases with use and care (feeding, battling together); higher bond unlocks a passive trait slot.

## 5. Combat

- Real-time, third-person, one active creature "out" at a time (player commands it; can swap between team members mid-fight, WoW/ARPG-pet-hybrid style rather than turn-based).
- Each creature has 4 abilities on a hotbar (cooldown-based) + a positioning/dodge mechanic for the player.
- PvE: wild creature fights, dungeon bosses, world bosses (raid-scale, 10–20 players).
- PvP: 1v1 and 3v3 team arena queues, ranked seasonally; open-world PvP is opt-in only (flagged zones), never forced — avoids toxic ganking driving away casual players.

## 6. Progression

- **Player level**: unlocks zones, roster slots, and crafting recipes.
- **Creature level/evolution**: the primary long-term collection loop.
- **Reputation** per Shard: unlocks vendors, cosmetics, and harder spawn variants (shiny-equivalent rare-color creatures).
- No hard level-gated "raid or die" endgame wall — endgame is horizontal (more Shards, PvP ranks, rare evolutions, cosmetics, guild projects) rather than a single vertical gear treadmill.

## 7. Social & guilds

- Guilds with a shared hall, guild bank, and guild-only crafting stations.
- Auction house in the hub city for trading creatures/items (with anti-RMT rate limiting/logging from day one).
- Friends list, party finder for dungeons/world bosses.

## 8. Monetization (no pay-to-win)

- Cosmetic skins for creatures and player avatars.
- Convenience: extra storage box slots, faster travel passes.
- Battle pass style seasonal cosmetic track.
- Explicitly **not sold**: stat-boosting items, exclusive powerful creatures, capture-rate boosts beyond a small QoL cap.

## 9. MVP scope (first playable milestone)

To validate the core loop before investing in full MMO-scale infrastructure:

1. 1 Shard (1 open-world zone + 1 hub), ~12 creature species with 2 evolution stages each (24–36 total forms).
2. Capture, level, evolve, and basic real-time combat working end-to-end, single small server instance (~20–50 concurrent players).
3. Basic party + 1 dungeon.
4. No PvP, no auction house yet — added in milestone 2 once the core loop is fun.

See [`docs/TECHNICAL_PLAN.md`](TECHNICAL_PLAN.md) for the engineering roadmap and architecture behind this milestone plan.
