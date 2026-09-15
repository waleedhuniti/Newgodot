import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth";
import characterRoutes from "./routes/characters";
import speciesRoutes from "./routes/species";

const app = express();
app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => res.json({ ok: true }));

app.use("/auth", authRoutes);
app.use("/characters", characterRoutes);
app.use("/species", speciesRoutes);

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
app.listen(PORT, () => {
  console.log(`backend API listening on :${PORT}`);
});
