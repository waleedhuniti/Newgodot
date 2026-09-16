# Archived: t5c engineering base

This is the [t5c](https://github.com/orion3dgames/t5c) (MIT license) Babylon.js +
Colyseus codebase this project was built on, plus its own upstream `construction/`
source-asset folder. It's kept here for reference and because the many bug fixes
and quest/content work done on top of it (see git history) are real, useful work -
not because the project is still built on it.

Retired because the base itself (a small solo-dev hobby project, not a maintained
framework) kept surfacing rough edges - crashes, silently-corrupting bugs, an
unreachable navmesh pocket in its stock town map - faster than they could be fixed,
and the client's dated look/feel wasn't something reskinning alone was fixing.

The project's design docs (`../../docs/`) and sourced art (`../../art/`) carry over
unchanged - only the engine/code here is retired. See `../../docs/TECHNICAL_PLAN.md`
for the current stack.

To run this archived version: `cd archive/t5c-base && npm install`, then
`npm run server-dev` / `npm run client-dev` per its own `README.md`/`.github` (not
carried over) - it's an unmodified drop of what was `<repo root>/` before.
