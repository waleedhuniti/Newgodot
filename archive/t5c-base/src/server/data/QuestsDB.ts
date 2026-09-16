import { QuestObjective } from "../../shared/types";

let QuestsDB = {
    // Tutorial quest - MQ04/MQ05 in docs/QUESTLINE_ACT1.md ("Earning Trust" / "The Bond").
    // Talk to the wild Wyrmling once to approach it, talk again to complete the bond.
    // TODO: this stands in for the real capture mechanic (docs/GAME_DESIGN.md §4.2) until
    // that's built - completing it should eventually add the creature to the player's
    // roster instead of just granting XP.
    MQ_FIRST_CONTACT: {
        key: "MQ_FIRST_CONTACT",
        title: "The Bond",
        description:
            "A small creature watches you from a few steps away, curious but wary. It doesn't feel dangerous - just uncertain, the way you probably look to it too. Approach slowly.",
        objective: "@NpcName seems to be waiting to see what you'll do.",
        type: QuestObjective.TALK_TO,
        location: "arrival_clearing",
        spawn_key: "arrival_wyrmling",
        quantity: 1,
        isRepeatable: false,
        rewards: {
            experience: 200,
            gold: 0,
            items: [],
        },
    },
    // MQ06 in docs/QUESTLINE_ACT1.md ("A Voice From Elsewhere"). Talk to the Dessa Vail
    // signal NPC in arrival_clearing once to hear her intro, talk again to complete it -
    // same TALK_TO pattern as MQ_FIRST_CONTACT. Completing it opens the portal to Origin
    // (see LocationsDB.ts arrival_clearing's `requires_quest_completed` interactive point).
    MQ06_VOICE_FROM_ORIGIN: {
        key: "MQ06_VOICE_FROM_ORIGIN",
        title: "A Voice From Elsewhere",
        description:
            "A flickering, translucent shape resolves a few steps away - not quite solid, more like a signal finding its shape. It's watching you, and it clearly expected you to be able to see it.",
        objective: "Listen to what the signal calling itself Dessa Vail has to say.",
        type: QuestObjective.TALK_TO,
        location: "arrival_clearing",
        spawn_key: "arrival_dessa_signal",
        quantity: 1,
        isRepeatable: false,
        rewards: {
            experience: 150,
            gold: 0,
            items: [],
        },
    },
    // MQ07 in docs/QUESTLINE_ACT1.md ("Welcome to Origin"). Giver is Dessa Vail again, this
    // time in person at Origin (the lh_town location, reflavored - see TECHNICAL_PLAN.md §4.5).
    MQ07_WELCOME_TO_ORIGIN: {
        key: "MQ07_WELCOME_TO_ORIGIN",
        title: "Welcome to Origin",
        description: "The signal you spoke with in the clearing turns out to have a body after all - Dessa Vail, waiting just past the portal.",
        objective: "Talk to Dessa Vail at Origin.",
        type: QuestObjective.TALK_TO,
        location: "lh_town",
        spawn_key: "origin_dessa",
        quantity: 1,
        isRepeatable: false,
        rewards: {
            experience: 150,
            gold: 50,
            items: [],
        },
    },
    LH_DANGEROUS_ERRANDS_01: {
        key: "LH_DANGEROUS_ERRANDS_01", // unique id
        title: "Dangerous Errands",
        description:
            "If you have a moment, please go to the forest to the south. It is currently plagued by a bandit invasion, perhaps you could offer some assistance in this matter?",
        objective: "@NpcName in @LocationName wants you to kill @KillRequired @TargetName found south of Eldoria.",
        type: QuestObjective.KILL_AMOUNT,
        location: "lh_town",
        spawn_key: "lh_town_bandits",
        quantity: 5,
        isRepeatable: false,
        rewards: {
            experience: 500,
            gold: 50,
            items: [],
        },
    },
    /*
    LH_DANGEROUS_ERRANDS_03: {
        key: "LH_DANGEROUS_ERRANDS_03", // unique id
        title: "Find Alexander The Righteous",
        description:
            "a very close friend of mine called Alexander has been since a few days, could you find him for me? He was last seen heading to the mountains to find monsters.",
        objective: "@NpcName in @LocationName wants you to find @TargetName in the mountains to the west of the temple.",
        type: QuestObjective.TALK_TO,
        location: "lh_town",
        spawn_key: "lh_town_alexander",
        quantity: 1,
        isRepeatable: false,
        rewards: {
            experience: 10000,
        },
    },*/
};

export { QuestsDB };
