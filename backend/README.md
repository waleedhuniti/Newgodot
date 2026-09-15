# Backend API

Express + Prisma + PostgreSQL REST API: accounts, auth, characters, species.

## Setup

1. Have Postgres running locally, with a database and user matching `.env` (see `.env.example`).
2. From the **repo root**: `npm install` (this is an npm workspace, not a standalone package).
3. From `backend/`:
   ```
   cp .env.example .env   # edit DATABASE_URL / JWT_SECRET as needed
   npx prisma migrate dev
   npx prisma db seed
   ```
4. Run it: from the repo root, `npm run dev:backend` (or `npx tsx src/index.ts` from inside `backend/`).

Health check: `GET http://localhost:4000/health` → `{"ok":true}`.

## Endpoints (MVP)

- `POST /auth/register` `{email, password}` → `{token}`
- `POST /auth/login` `{email, password}` → `{token}`
- `GET /species` → list of species definitions
- `POST /characters` (auth required) `{name, starterSpeciesKey}` → creates a character bonded with a Tier 1 starter creature
- `GET /characters` (auth required) → list of the account's characters with their creatures

Auth: send `Authorization: Bearer <token>` on protected routes.
