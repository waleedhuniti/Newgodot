# Species: Duskwyrm

Our first real (non-placeholder, cleared-license) creature model. Maps the CC-BY sourced dragon model to the game's creature system.

- **Source model**: `art/creatures/sources/oscar-creativo-dragon/` — "Dragon Character 3d" by Oscar Creativo, CC-BY (see that folder's `ATTRIBUTION.md`)
- **Type**: Shade (see `docs/GAME_DESIGN.md` §4.1) — dark blue-gray/black coloring, aggressive silhouette
- **Tier**: 3 (final evolution) — imposing scale and detail fit an end-of-line form rather than a starter
- **Silhouette**: muscular bipedal dragon, large membrane wings, spiked head crest, long tail, clawed hands and feet
- **Rig status**: pre-rigged, 99-bone AccuRIG-style skeleton (`RL_BoneRoot` root), includes one embedded placeholder animation ("TempMotion") not intended for final use
- **Animation status**: a procedural test animation (idle sway + wing flap + tail wave) was built and rendered as a capability check — functional but stiff (pure sine-wave keyframing, no hand-tuned easing/weight). Needs real animator pass or a proper motion-capture/library source before it's shippable quality. See `docs/TECHNICAL_PLAN.md` for the broader animation-quality discussion.

## Evolution line context

Needs Tier 1 and Tier 2 forms designed to lead into this (smaller/younger dragon, fewer spikes, less developed wings) — not yet sourced or designed. Flag as follow-up work when naming the fuller species roster.

## Outstanding work before this is game-ready

1. Real animation pass (idle, walk, attack, hit, death at minimum) — either hand-animated in Blender, sourced from a compatible motion library, or a proper AI animation service
2. Tier 1/Tier 2 pre-evolution models
3. In-game credits screen entry per `ATTRIBUTION.md`'s CC-BY requirement
4. Export/optimize for Unity (verify UDIM textures import correctly or need atlasing; Unity's default material import doesn't always handle multi-UDIM cleanly)
