const API_BASE = "http://localhost:4000";

interface AuthResponse {
  token: string;
}

interface Species {
  id: string;
  key: string;
  name: string;
  type: string;
  tier: number;
}

interface CreatureInstance {
  id: string;
  species: Species;
  nickname: string | null;
  level: number;
}

interface CharacterDto {
  id: string;
  name: string;
  level: number;
  creatures: CreatureInstance[];
}

async function postJson<T>(path: string, body: unknown, token?: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const errBody = await res.json().catch(() => ({}));
    throw new Error(`${path} failed (${res.status}): ${JSON.stringify(errBody)}`);
  }
  return res.json();
}

async function getJson<T>(path: string, token?: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok) {
    throw new Error(`${path} failed (${res.status})`);
  }
  return res.json();
}

// Registers a new account, or logs in if one already exists with this email.
export async function loginOrRegister(email: string, password: string): Promise<string> {
  try {
    const { token } = await postJson<AuthResponse>("/auth/register", { email, password });
    return token;
  } catch {
    const { token } = await postJson<AuthResponse>("/auth/login", { email, password });
    return token;
  }
}

export async function getOrCreateCharacter(token: string, name: string): Promise<CharacterDto> {
  const characters = await getJson<CharacterDto[]>("/characters", token);
  if (characters.length > 0) {
    return characters[0];
  }
  return postJson<CharacterDto>("/characters", { name, starterSpeciesKey: "wyrmling" }, token);
}
