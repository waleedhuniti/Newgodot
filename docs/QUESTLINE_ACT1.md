# Act 1 Questline — "First Contact" (full quest list)

Expands the Act 1 beats in [`docs/STORY.md`](STORY.md) §1 into individual, scriptable quests for the MVP Shard. Terminology from [`docs/WORLD_LORE.md`](WORLD_LORE.md).

Quest ID prefixes: **MQ** = main quest (required, linear), **SQ** = side quest (optional), **BQ** = bounty (repeatable).

---

## Chapter 1 — Arrival

### MQ01 — The Glitch
- **Giver**: none (cinematic/scripted intro)
- **Objective**: Experience the glitch in the real world; follow the flicker to a tear in reality; step through.
- **Dialogue (player's inner thought, on-screen text)**: *"That sound again. Like the world skipped a frame. Nobody else even looks up."* → *"It's still there. It's... a door."*
- **Reward**: none (pure intro)

### MQ02 — First Steps in the Continuum
- **Giver**: none (tutorial prompts)
- **Objective**: Learn movement/camera; walk through the entry clearing of the Shard.
- **Design note**: environment should visually sell "this is not Earth" immediately — color grading shift, impossible geometry at the edges of the clearing.
- **Reward**: none

### MQ03 — Something's Watching
- **Giver**: none (triggered encounter)
- **Objective**: A wild Emergent (the eventual starter) appears at a distance, watches the player, and flees if approached carelessly. Teaches the approach/stealth-adjacent mechanic (move slowly = it stays; run at it = it bolts).
- **Reward**: none

---

## Chapter 2 — The Bond

### MQ04 — Earning Trust
- **Giver**: none (continued encounter from MQ03)
- **Objective**: Approach the starter Emergent correctly 3 times (it gets closer each time) without spooking it.
- **Dialogue (Emergent has no speech; use body-language animation cues)**: none — deliberately silent, contrasted with the very talkative NPCs coming up.
- **Reward**: none

### MQ05 — The Bond (capture tutorial)
- **Giver**: none
- **Objective**: A small, weak wild Null-touched creature threatens the starter Emergent. Player fights it off (very easy, tutorial-tuned), then completes the capture/bond QTE (§4.2 of `GAME_DESIGN.md`) with the now-trusting Emergent.
- **Dialogue**: on-screen prompt: *"It's not caught. It's choosing you too."*
- **Reward**: Starter Emergent joins roster; first roster/inventory UI tutorial popup.

### SQ01 — Getting to Know Each Other (optional, same area)
- **Giver**: none (contextual)
- **Objective**: Use each of the starter Emergent's 2 starting abilities on nearby harmless wildlife/props to see what they do.
- **Reward**: Small XP, unlocks the ability-hotbar tutorial tooltip permanently dismissed.

---

## Chapter 3 — Signal from Origin

### MQ06 — A Voice From Elsewhere
- **Giver**: Dessa Vail (remote contact — appears as a translucent "signal" projection, not in person yet)
- **Objective**: Listen to Dessa's introduction; she explains, briefly, what an Anchor is and invites the player to Origin.
- **Dialogue (Dessa)**: *"You felt the pull, and you didn't run from it — that already puts you ahead of most people who ever will. I'm Dessa Vail. I coordinate things from Origin. You'll have questions. Come find me, and I'll do my best."*
- **Reward**: Portal to Origin unlocked.

### MQ07 — Welcome to Origin
- **Giver**: Dessa Vail (in person, Origin hub)
- **Objective**: Meet Dessa at Origin; tutorial tour of the hub (bank, marketplace stall, guild hall exterior, Resequencing Spire).
- **Dialogue (Dessa)**: *"This is Origin. Built by Anchors, for Anchors — the one place in the Continuum that didn't happen to us, we made it happen. Bank's there if you want somewhere safer than your pockets. Market's there. And that spire — that's where your partner will Ascend, when it's ready. Not yet, though."*
- **Reward**: Small starting currency, marketplace unlocked.

### SQ02 — Meet the Regulars (optional)
- **Giver**: Dessa Vail
- **Objective**: Talk to 3 background Origin NPCs (flavor-only, establishes Origin as lived-in rather than a menu with a skybox).
- **Reward**: Small XP, cosmetic cheap item from the marketplace vendor.

---

## Chapter 4 — First Surge

### MQ08 — Something's Wrong at the Clearing
- **Giver**: Dessa Vail
- **Objective**: Return to the starting Shard — a small Null Surge is corrupting the area around the clearing where the player found their starter.
- **Dialogue (Dessa, remote)**: *"It's small — a minor Surge, nothing you can't handle with your partner. But get there before it spreads. Some of those Emergents in that clearing aren't equipped to fight anything, let alone something like this."*
- **Reward**: none (leads into MQ09)

### MQ09 — Hold the Clearing
- **Giver**: continued from MQ08
- **Objective**: Defeat 5 Null-corrupted minor enemies threatening the clearing's native wild Emergents. First real combat encounter using the full ability hotbar.
- **Dialogue (on completion, Dessa remote)**: *"Good. That's more than most first-timers manage without a scratch. ...I mean that as a compliment, by the way."*
- **Reward**: XP, first evolution catalyst fragment (not enough to Ascend yet — teaches the catalyst-collection loop).

### SQ03 — Aftermath (optional)
- **Giver**: a wild Emergent in the clearing (non-verbal quest marker)
- **Objective**: Escort the frightened native Emergents back to a safe spot in the clearing.
- **Reward**: Small XP, minor Bond-meter boost for the starter Emergent (reinforces "caring for Emergents" theming).

---

## Chapter 5 — Rho's Warning

### MQ10 — The Old Anchor
- **Giver**: Dessa Vail (directs player to Rho)
- **Objective**: Travel to Rho's dwelling (a quiet, out-of-the-way corner of the Shard, visually distinct — long-settled, personal, unlike the wilder open zones).
- **Dialogue (Dessa)**: *"There's someone who's been doing this longer than anyone — longer than Origin's existed, even. Rho doesn't get visitors much. Might be worth changing that, given what you just saw."*
- **Reward**: none

### MQ11 — A Longer Memory
- **Giver**: Rho
- **Objective**: Dialogue-only quest — Rho examines the player's catalyst fragment and grows quiet.
- **Dialogue (Rho)**: *"I've watched Surges happen for a very long time. They used to be accidents — data finding the wrong shape by chance. This one wasn't an accident. Something pushed it. I don't like coincidences, and I especially don't like this one happening right as someone new crosses over."*
- **Player dialogue option**: *"Are you saying it's connected to me?"* → Rho: *"No. I'm saying I don't know yet, and that scares me more than if I did."*
- **Reward**: XP, Rho added as a recurring quest-giver.

### SQ04 — Rho's Request (optional)
- **Giver**: Rho
- **Objective**: Collect 5 stable (non-corrupted) data-samples from around the Shard for Rho to study.
- **Reward**: Moderate XP, a cosmetic item themed around Rho's era (visually "older," establishes in-world material culture has changed over time).

---

## Chapter 6 — The Rival

### MQ12 — A Challenger
- **Giver**: Kess (ambushes the player near Origin's arena entrance)
- **Objective**: Dialogue then a scripted 1v1 PvP tutorial battle against Kess (tuned so the player can win, but Kess is clearly skilled).
- **Dialogue (Kess)**: *"You're the one who calmed a whole Surge site on your first week? I had to see that for myself. Don't worry — I'm not here to make you regret leaving your house. I'm here because I want a real match, and everyone else around here fights like they're apologizing."*
- **Reward**: XP, arena queue unlocked, Kess added as a recurring character.

### SQ05 — Training Match (optional, repeatable once)
- **Giver**: Kess
- **Objective**: Rematch Kess with a harder tuning.
- **Dialogue (Kess, on loss or win)**: win: *"Okay. Okay! That one counts."* / loss: *"Still counts as fun. Rematch, whenever."*
- **Reward**: Small currency.

---

## Chapter 7 — Into the Depths (dungeon)

### MQ13 — A Denser Signal
- **Giver**: Rho
- **Objective**: Rho has traced unusually dense, organized Null activity to a specific location — the Shard's dungeon entrance.
- **Dialogue (Rho)**: *"I want to be wrong about this. Go carefully. If there's a pattern behind what's happening, this is where we'll see it first."*
- **Reward**: none

### MQ14 — Descent (dungeon, wave 1-2)
- **Giver**: continued from MQ13
- **Objective**: Clear the first two encounter rooms of the dungeon (party-recommended, soloable at tutorial difficulty for MVP testing purposes).
- **Reward**: XP, gear/item drops.

### MQ15 — The Pattern
- **Giver**: continued (mid-dungeon discovery)
- **Objective**: Discover a chamber where Null enemies are unnaturally organized — moving with clear intent rather than random hostility.
- **Dialogue (Rho, remote)**: *"That's not how they behave. That has never been how they behave."*
- **Reward**: none

### MQ16 — Dungeon Boss
- **Giver**: continued
- **Objective**: Defeat the dungeon's boss encounter (a large, unstable Null formation).
- **Reward**: Significant XP, guaranteed evolution catalyst (enough to Ascend the starter Emergent, if Bond/level requirements are met), rare cosmetic drop chance.

### MQ17 — The Watcher (finale / cliffhanger)
- **Giver**: continued (post-boss)
- **Objective**: In the boss chamber's aftermath, a distant, uniquely stable and intelligent Null entity is briefly glimpsed observing the player before vanishing without engaging.
- **Dialogue (Rho, remote, subdued)**: *"...I need you to describe exactly what you just saw. Word for word. Please."*
- **Reward**: Major XP, completes Act 1. Unlocks: Ascension at the Resequencing Spire (if not already triggered), full Origin services, arena ranked queue, guild creation.

---

## Bounty board (repeatable, unlocked after MQ09)

### BQ01 — Surge Cleanup
- **Giver**: Anchor Concordat bounty board (Origin)
- **Objective**: Defeat a rotating number of Null enemies in the open-world Shard zones.
- **Reward**: Currency + small catalyst-fragment chance, repeatable on a cooldown.

### BQ02 — Gathering Run
- **Giver**: bounty board
- **Objective**: Collect a rotating gathering-node resource in the Shard.
- **Reward**: Currency, crafting materials.

### BQ03 — Escort
- **Giver**: bounty board
- **Objective**: Escort a native wild Emergent NPC between two points in the Shard, fending off Null interference.
- **Reward**: Currency, Bond-meter boost for the player's active Emergent.

---

## Summary count

- **17 main quests** (MQ01-MQ17) — the required critical path from arrival through the Act 1 dungeon finale
- **5 side quests** (SQ01-SQ05) — optional flavor/character-building content along the way
- **3 repeatable bounties** (BQ01-BQ03) — post-MQ09 evergreen content to fill time between main quest chapters

This is scoped to be fully buildable within the MVP milestone (§9 of `GAME_DESIGN.md`, §6 of `TECHNICAL_PLAN.md`) — one Shard, one hub, one dungeon — while giving the single Shard enough narrative density that it doesn't feel like a placeholder tutorial. Chapter breaks (1-7) map cleanly to future voice-over/cutscene budget planning if that's ever in scope.
