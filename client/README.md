# Client

Three.js + Vite web client. Talks to `backend` (auth/characters over HTTP) and `realtime` (live world state over WebSocket).

## Run it

Backend and realtime must already be running (see their READMEs). Then, from the repo root: `npm run dev:client`, or `npx vite` from inside `client/`. Open the printed local URL (default `http://localhost:5173`).

Enter any email/password — the login form registers a new account automatically if that email doesn't exist yet, or logs in if it does. It also creates a starter character (Wyrmling) on first login if the account has none.

Controls: WASD (or arrow keys) to move.

## Current state

- Ground plane and red cone markers are **placeholders** standing in for a real map and monster models (`src/scene.ts` — `setupGround()` / `setupMonsterMarkers()`). Swapping in real assets only touches this file.
- Movement and multiplayer position sync are real and working — verified with a headless-browser test (two simultaneous sessions, each seeing the other move live).
- No capture/combat/UI beyond the login form and a minimal HUD yet — see `docs/TECHNICAL_PLAN.md` §6 for what's next.

## Structure

- `src/api.ts` — REST calls to the backend (login/register, character lookup/creation)
- `src/scene.ts` — Three.js scene setup, player mesh management, camera
- `src/main.ts` — wires the login form, Colyseus connection, input handling, and the render loop together
