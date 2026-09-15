import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "../db";
import { signToken } from "../auth";

const router = Router();

const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(128),
});

router.post("/register", async (req, res) => {
  const parsed = credentialsSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }
  const { email, password } = parsed.data;

  const existing = await prisma.account.findUnique({ where: { email } });
  if (existing) {
    return res.status(409).json({ error: "email already registered" });
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const account = await prisma.account.create({
    data: { email, passwordHash },
  });

  const token = signToken({ accountId: account.id, email: account.email });
  res.status(201).json({ token });
});

router.post("/login", async (req, res) => {
  const parsed = credentialsSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }
  const { email, password } = parsed.data;

  const account = await prisma.account.findUnique({ where: { email } });
  if (!account) {
    return res.status(401).json({ error: "invalid credentials" });
  }
  const valid = await bcrypt.compare(password, account.passwordHash);
  if (!valid) {
    return res.status(401).json({ error: "invalid credentials" });
  }

  const token = signToken({ accountId: account.id, email: account.email });
  res.json({ token });
});

export default router;
