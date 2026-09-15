# Realtime server

Colyseus authoritative game server. Each Shard (docs/WORLD_LORE.md §2) is a room instance of `ShardRoom`.

## Setup

From the repo root: `npm install` (npm workspace). The backend must be running first (see `backend/README.md`) so clients have a JWT to join with.

Run it: `JWT_SECRET=<same value as backend's .env> npm run dev:realtime` from the repo root, or `JWT_SECRET=... npx tsx src/index.ts` from inside `realtime/`. **`JWT_SECRET` must match the backend's** — the room verifies the token the backend issued.

Default port: `2567`.

## Joining a room (client side)

Using `colyseus.js`:

```js
const client = new Client("ws://localhost:2567");
const room = await client.joinOrCreate("shard_starter", {
  token: jwtFromBackendLogin,
  characterId: character.id,
  characterName: character.name,
});

room.send("move", { x, y, z, rotationY });
room.state.players.forEach((player, sessionId) => { /* ... */ });
```

## Gotcha already hit (read before touching schema code)

`@colyseus/schema`'s `@type()` decorators need `"useDefineForClassFields": false` in `tsconfig.json` — without it, TypeScript's ES2022+ class-field semantics silently overwrite the decorator-defined property and state sync does nothing (no error, just empty state on clients). Already set correctly in this package's `tsconfig.json` — don't remove it.
