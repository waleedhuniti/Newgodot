// Shared types between backend (REST/persistence) and realtime (Colyseus) servers.
// Keep this dependency-free (no Prisma/Express/Colyseus imports) so both sides can use it.

export const ELEMENT_TYPES = [
  "FLAME",
  "TIDE",
  "VERDANT",
  "STONE",
  "GALE",
  "VOLT",
  "SHADE",
  "RADIANT",
] as const;

export type ElementType = (typeof ELEMENT_TYPES)[number];

export interface JwtPayload {
  accountId: string;
  email: string;
}

export interface MoveMessage {
  x: number;
  y: number;
  z: number;
  rotationY: number;
}

export interface CaptureAttemptMessage {
  wildSpawnId: string;
}

export interface CaptureResultMessage {
  wildSpawnId: string;
  success: boolean;
  creatureInstanceId?: string;
}
