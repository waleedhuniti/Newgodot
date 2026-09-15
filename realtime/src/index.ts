import { Server } from "colyseus";
import { createServer } from "http";
import { ShardRoom } from "./rooms/ShardRoom";

const PORT = process.env.PORT ? Number(process.env.PORT) : 2567;

const httpServer = createServer();
const gameServer = new Server({ server: httpServer });

// MVP has one Shard; docs/TECHNICAL_PLAN.md §3 defines more Shards as
// more room definitions/instances of the same ShardRoom class.
gameServer.define("shard_starter", ShardRoom);

httpServer.listen(PORT, () => {
  console.log(`realtime server listening on :${PORT}`);
});
