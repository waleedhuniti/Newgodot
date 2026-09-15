import { Room, Client } from "colyseus";
import jwt from "jsonwebtoken";
import type { JwtPayload, MoveMessage } from "@creature-mmo/shared";
import { ShardState, PlayerState } from "../schema/ShardState";

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error("JWT_SECRET env var is required");
}

interface JoinOptions {
  token: string;
  characterId: string;
  characterName: string;
}

// One instance of this room = one Shard zone (docs/WORLD_LORE.md §2).
// MVP has a single Shard ("shard_starter"); more Shards are more room
// instances of this same class per docs/TECHNICAL_PLAN.md §3.
export class ShardRoom extends Room<ShardState> {
  maxClients = 64;

  onCreate() {
    this.setState(new ShardState());

    this.onMessage<MoveMessage>("move", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (!player) return;
      player.x = message.x;
      player.y = message.y;
      player.z = message.z;
      player.rotationY = message.rotationY;
    });
  }

  onAuth(_client: Client, options: JoinOptions): JwtPayload {
    // Verifies the JWT the backend API issued at login — the realtime
    // server never sees a password, only a token it can validate itself.
    return jwt.verify(options.token, JWT_SECRET as string) as JwtPayload;
  }

  onJoin(client: Client, options: JoinOptions) {
    const player = new PlayerState();
    player.characterId = options.characterId;
    player.name = options.characterName;
    this.state.players.set(client.sessionId, player);
    console.log(`${options.characterName} joined room ${this.roomId} (${client.sessionId})`);
  }

  onLeave(client: Client) {
    this.state.players.delete(client.sessionId);
  }
}
