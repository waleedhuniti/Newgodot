import Logger from "../../utils/Logger";
import { Leveling } from "../../../shared/Class/Leveling";
import { randomNumberInRange } from "../../../shared/Utils";
import { GetLoot } from "../../../shared/Class/LootTable";
import { nanoid } from "nanoid";
import { LootSchema } from "../schema/LootSchema";
import { PlayerSchema } from "../schema";
import { ServerMsg } from "../../../shared/types";

export class dropCTRL {
    private _owner: PlayerSchema;
    private _client;

    constructor(owner, client) {
        this._owner = owner;
        this._client = client;
    }

    public addExperience(target) {
        // calculate experience total - AI_SPAWN_INFO (the raw LocationsDB spawn entry) wins
        // if it overrides the race default, else fall back to the resolved value spawnCTRL
        // already put on the entity itself. Both are validated before use: a spawn/race
        // missing this entirely, or defining it as a bare number instead of {min,max},
        // must not reach randomNumberInRange - that silently produces NaN, which then
        // permanently corrupts player_data.experience (NaN + anything is still NaN).
        let exp = target.AI_SPAWN_INFO?.experienceGain ?? target.experienceGain;
        if (!exp || typeof exp.min !== "number" || typeof exp.max !== "number") {
            return;
        }
        let amount = Math.floor(randomNumberInRange(exp.min, exp.max));
        Leveling.addExperience(this._owner, amount);
        console.log("[addExperience]", amount);
    }

    public addGold(target) {
        // same reasoning as addExperience - target.goldGain doesn't exist at all on a
        // PlayerSchema (PvP kills), and used to throw here reading .min off undefined.
        let goldGains = target.AI_SPAWN_INFO?.goldGain ?? target.goldGain;
        if (!goldGains || typeof goldGains.min !== "number" || typeof goldGains.max !== "number") {
            return;
        }
        if (goldGains.min && goldGains.max) {
            let gold = Math.floor(randomNumberInRange(goldGains.min, goldGains.max));
            this._owner.player_data.gold += gold;

            Logger.info(`[gameroom][addGold] player has gained ${gold} gold, total: ${this._owner.player_data.gold}`);

            // inform player
            this._client.send(ServerMsg.SERVER_MESSAGE, {
                type: "event",
                message: "You pick up " + gold + " worth of gold.",
                date: new Date(),
            });
        }
    }

    public dropItems(target) {
        // target.AI_SPAWN_INFO is null for a PlayerSchema (PvP kills have no spawn entry) -
        // used to throw here reading .drops off it directly.
        let items = target.AI_SPAWN_INFO?.drops ?? target.drops ?? [];
        let loot = GetLoot(items);
        loot.forEach((drop) => {
            // drop item on the ground
            let sessionId = nanoid(10);
            let currentPosition = target.getPosition();
            currentPosition.x += randomNumberInRange(-2, 2);
            currentPosition.z += randomNumberInRange(-2, 2);
            let data = {
                key: drop.id,
                sessionId: sessionId,
                x: currentPosition.x,
                y: 0.25,
                z: currentPosition.z,
                qty: drop.quantity,
            };
            let entity = new LootSchema(this._owner._state, data);
            this._owner._state.entities.set(sessionId, entity);
        });
    }
}
