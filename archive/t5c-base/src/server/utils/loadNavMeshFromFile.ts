///////////////////////////////////////////////////////////
// CAPTAIN OBVIOUS HERE:
// this can only be used in a NODE ENVIRONMENT, do not use to import in the client as fs is not available.

import fs from "fs";
import path from "path";
import { NavMeshLoader, NavMesh } from "../../shared/Libs/yuka-min";

export default async function loadNavMeshFromFile(fileNameNavMesh: string): Promise<NavMesh> {
    const url = path.join(__dirname, "../../../public/models/navmesh/" + fileNameNavMesh + ".glb");
    console.log(url);
    const data = await fs.readFileSync(url);
    // Buffer.buffer is the underlying ArrayBuffer, which for small files is a slice of
    // Node's shared allocation pool (default 8KB) rather than one sized to the file - using
    // it directly hands the parser several KB of unrelated pool memory past the real content,
    // which it then tries to read as more GLB chunks. Never surfaced before because every
    // stock navmesh here happens to be too large to get pooled; this one (a simple flat
    // plane) is the first small enough to hit it.
    const arrayBuffer = data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength);
    const loader = new NavMeshLoader();
    return loader.parse(arrayBuffer, "", { mergeConvexRegions: false }).then((navmesh) => {
        return navmesh;
    });
}
