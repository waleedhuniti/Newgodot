import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  // Tier 1 starter of the Duskwyrm line. Tier 2 form not yet designed
  // (see art/creatures/species/duskwyrm.md) — Wyrmling evolves directly
  // into Duskwyrm for now as an MVP placeholder.
  const wyrmling = await prisma.species.upsert({
    where: { key: "wyrmling" },
    update: {},
    create: {
      key: "wyrmling",
      name: "Wyrmling",
      type: "SHADE",
      tier: 1,
      baseHp: 32,
      baseAttack: 8,
      baseDefense: 6,
      baseSpeed: 9,
      baseFocus: 7,
    },
  });

  await prisma.species.upsert({
    where: { key: "duskwyrm" },
    update: {},
    create: {
      key: "duskwyrm",
      name: "Duskwyrm",
      type: "SHADE",
      tier: 3,
      baseHp: 140,
      baseAttack: 34,
      baseDefense: 26,
      baseSpeed: 22,
      baseFocus: 20,
      evolvesFromId: wyrmling.id,
    },
  });

  console.log("Seeded species: wyrmling, duskwyrm");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
