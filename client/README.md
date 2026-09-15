# Client

Three.js + Vite web client. Talks to `backend` (auth/characters over HTTP) and `realtime` (live world state over WebSocket).

## Run it

Backend and realtime must already be running (see their READMEs). Then, from the repo root: `npm run dev:client`, or `npx vite` from inside `client/`. Open the printed local URL (default `http://localhost:5173`).

Enter any email/password — the login form registers a new account automatically if that email doesn't exist yet, or logs in if it does. It also creates a starter character (Wyrmling) on first login if the account has none.

Controls: WASD (or arrow keys) to move.

## Current state

- Ground plane is still a **placeholder** flat grid standing in for a real map (`src/scene.ts` — `setupGround()`). Swapping in a real map model only touches this function.
- Monster spawns are **real models** now: Bat, Skeleton, Dragon, and Slime from Quaternius's CC0 "Animated Monster Pack" (`art/creatures/quaternius-animated-monster-pack/`), converted to glTF and loaded via `GLTFLoader` in `setupMonsterMarkers()`, each playing its idle/flying animation clip through `THREE.AnimationMixer`. Static placement for now — no wild-spawn logic or capture interaction yet.
- Movement and multiplayer position sync are real and working — verified with a headless-browser test (two simultaneous sessions, each seeing the other move live).
- No capture/combat/UI beyond the login form and a minimal HUD yet — see `docs/TECHNICAL_PLAN.md` §6 for what's next.
- Model files live in `public/models/*.glb` (Vite serves `public/` at the site root, hence `/models/Dragon.glb` paths in `scene.ts`). Re-run the Blender conversion (see `art/creatures/quaternius-animated-monster-pack/ATTRIBUTION.md`) if the source FBX ever changes.

## Structure

- `src/api.ts` — REST calls to the backend (login/register, character lookup/creation)
- `src/scene.ts` — Three.js scene setup, player mesh management, camera
- `src/main.ts` — wires the login form, Colyseus connection, input handling, and the render loop together
