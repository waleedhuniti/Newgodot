import { Router } from "express";
import { prisma } from "../db";

const router = Router();

router.get("/", async (_req, res) => {
  const species = await prisma.species.findMany({
    orderBy: [{ tier: "asc" }, { name: "asc" }],
  });
  res.json(species);
});

export default router;
