import { Router } from "express";
import { z } from "zod";
import { prisma } from "../db";
import { requireAuth, AuthedRequest } from "../auth";

const router = Router();
router.use(requireAuth);

const createCharacterSchema = z.object({
  name: z.string().min(2).max(24),
  starterSpeciesKey: z.string(),
});

// POST /characters — create a character and bond its starter creature (MQ05 in docs/QUESTLINE_ACT1.md)
router.post("/", async (req: AuthedRequest, res) => {
  const parsed = createCharacterSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }
  const { name, starterSpeciesKey } = parsed.data;
  const accountId = req.auth!.accountId;

  const species = await prisma.species.findUnique({ where: { key: starterSpeciesKey } });
  if (!species || species.tier !== 1) {
    return res.status(400).json({ error: "invalid starter species" });
  }

  const existing = await prisma.character.findUnique({
    where: { accountId_name: { accountId, name } },
  });
  if (existing) {
    return res.status(409).json({ error: "character name already used on this account" });
  }

  const character = await prisma.character.create({
    data: {
      accountId,
      name,
      creatures: {
        create: {
          speciesId: species.id,
          currentHp: species.baseHp,
        },
      },
    },
    include: { creatures: { include: { species: true } } },
  });

  res.status(201).json(character);
});

router.get("/", async (req: AuthedRequest, res) => {
  const accountId = req.auth!.accountId;
  const characters = await prisma.character.findMany({
    where: { accountId },
    include: { creatures: { include: { species: true } } },
  });
  res.json(characters);
});

export default router;
