import jwt from "jsonwebtoken";
import { Request, Response, NextFunction } from "express";
import type { JwtPayload } from "@creature-mmo/shared";

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error("JWT_SECRET env var is required");
}

export function signToken(payload: JwtPayload): string {
  return jwt.sign(payload, JWT_SECRET as string, { expiresIn: "7d" });
}

export interface AuthedRequest extends Request {
  auth?: JwtPayload;
}

export function requireAuth(req: AuthedRequest, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    return res.status(401).json({ error: "missing bearer token" });
  }
  const token = header.slice("Bearer ".length);
  try {
    req.auth = jwt.verify(token, JWT_SECRET as string) as JwtPayload;
    next();
  } catch {
    return res.status(401).json({ error: "invalid or expired token" });
  }
}
