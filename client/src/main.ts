import { Client, Room } from "colyseus.js";
import { GameWorld } from "./scene";
import { loginOrRegister, getOrCreateCharacter } from "./api";

const REALTIME_URL = "ws://localhost:2567";
const MOVE_SPEED = 6; // units/sec
const MOVE_SEND_INTERVAL_MS = 100;

const loginEl = document.getElementById("login") as HTMLDivElement;
const loginForm = document.getElementById("login-form") as HTMLFormElement;
const loginError = document.getElementById("login-error") as HTMLDivElement;
const hudEl = document.getElementById("hud") as HTMLDivElement;
const hudName = document.getElementById("hud-name") as HTMLDivElement;
const hudPlayers = document.getElementById("hud-players") as HTMLDivElement;

let canvas = document.querySelector("canvas");
if (!canvas) {
  canvas = document.createElement("canvas");
  document.getElementById("app")!.appendChild(canvas);
}

const world = new GameWorld(canvas as HTMLCanvasElement);

const keys: Record<string, boolean> = {};
window.addEventListener("keydown", (e) => (keys[e.code] = true));
window.addEventListener("keyup", (e) => (keys[e.code] = false));

let room: Room | null = null;
let localPos = { x: 0, y: 0, z: 0 };
let lastSentAt = 0;
let lastSent = { x: 0, z: 0 };
const knownSessionIds = new Set<string>();

loginForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  loginError.textContent = "";

  const email = (document.getElementById("email") as HTMLInputElement).value;
  const password = (document.getElementById("password") as HTMLInputElement).value;
  const charName = (document.getElementById("charname") as HTMLInputElement).value || "Anchor";

  try {
    const token = await loginOrRegister(email, password);
    const character = await getOrCreateCharacter(token, charName);

    const client = new Client(REALTIME_URL);
    room = await client.joinOrCreate("shard_starter", {
      token,
      characterId: character.id,
      characterName: character.name,
    });

    world.setLocalSessionId(room.sessionId);
    loginEl.style.display = "none";
    hudEl.style.display = "block";
    hudName.textContent = `${character.name} (${character.creatures[0]?.species.name ?? "no creature"})`;

    requestAnimationFrame(gameLoop);
  } catch (err: any) {
    loginError.textContent = err.message ?? String(err);
  }
});

function gameLoop(timestamp: number) {
  requestAnimationFrame(gameLoop);
  if (!room) return;

  const dt = 1 / 60; // fine for an MVP client tick, not framerate-critical here
  let dx = 0;
  let dz = 0;
  if (keys["KeyW"] || keys["ArrowUp"]) dz -= 1;
  if (keys["KeyS"] || keys["ArrowDown"]) dz += 1;
  if (keys["KeyA"] || keys["ArrowLeft"]) dx -= 1;
  if (keys["KeyD"] || keys["ArrowRight"]) dx += 1;

  if (dx !== 0 || dz !== 0) {
    const len = Math.hypot(dx, dz);
    localPos.x += (dx / len) * MOVE_SPEED * dt;
    localPos.z += (dz / len) * MOVE_SPEED * dt;
  }

  world.upsertPlayer(room.sessionId, localPos.x, localPos.y, localPos.z);
  world.followCamera(localPos.x, localPos.y, localPos.z);

  if (
    timestamp - lastSentAt > MOVE_SEND_INTERVAL_MS &&
    (localPos.x !== lastSent.x || localPos.z !== lastSent.z)
  ) {
    room.send("move", { x: localPos.x, y: localPos.y, z: localPos.z, rotationY: 0 });
    lastSent = { x: localPos.x, z: localPos.z };
    lastSentAt = timestamp;
  }

  syncRemotePlayers();
  world.render();
}

function syncRemotePlayers() {
  if (!room) return;
  const seenThisFrame = new Set<string>();

  room.state.players.forEach((player: any, sessionId: string) => {
    seenThisFrame.add(sessionId);
    knownSessionIds.add(sessionId);
    if (sessionId === room!.sessionId) return; // local player already driven by input
    world.upsertPlayer(sessionId, player.x, player.y, player.z);
  });

  for (const id of knownSessionIds) {
    if (!seenThisFrame.has(id)) {
      world.removePlayer(id);
      knownSessionIds.delete(id);
    }
  }

  hudPlayers.textContent = `${seenThisFrame.size} player(s) in this Shard`;
}
