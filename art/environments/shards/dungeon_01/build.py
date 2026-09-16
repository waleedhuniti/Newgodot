"""
Builds the Act 1 dungeon hall (`shard_dungeon_01`) from KayKit Dungeon Remastered
pieces and writes it straight into the client's asset folders.

Run with Blender's bundled Python, headless, from anywhere:

    blender -b --python art/environments/shards/dungeon_01/build.py

Regenerates:
    public/models/environment/shard_dungeon_01.glb  (the visible mesh)
    public/models/navmesh/shard_dungeon_01.glb       (a simple flat walkable plane)

See docs/TECHNICAL_PLAN.md §2/§4 for how this is wired into LocationsDB.ts
(the `lh_dungeon_01` location) and the gotcha about small-file Buffer pooling
this navmesh format originally tripped on.
"""

import bpy, os, math

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
ASSET_DIR = os.path.join(REPO_ROOT, "art/environments/kaykit-dungeon-remastered/Assets/gltf")
ENV_OUT = os.path.join(REPO_ROOT, "public/models/environment/shard_dungeon_01.glb")
NAVMESH_OUT = os.path.join(REPO_ROOT, "public/models/navmesh/shard_dungeon_01.glb")

TILE = 4.0
TILES_X = 6  # long axis (entrance -> boss), 24m
TILES_Y = 4  # width, 16m


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in list(bpy.data.meshes):
        if block.users == 0:
            bpy.data.meshes.remove(block)


def import_piece(name):
    """Import a piece fresh (glTF import creates new objects each time)."""
    path = os.path.join(ASSET_DIR, name)
    before = set(bpy.data.objects.keys())
    bpy.ops.import_scene.gltf(filepath=path)
    after = set(bpy.data.objects.keys())
    new_names = list(after - before)
    # top-level (parentless) new objects are the roots we want to move
    return [bpy.data.objects[n] for n in new_names if bpy.data.objects[n].parent is None]


def place(name, x, y, z=0.0, rot_z_deg=0.0):
    for r in import_piece(name):
        r.location = (x, y, z)
        r.rotation_euler = (0, 0, math.radians(rot_z_deg))


def build_environment():
    clear_scene()

    hall_w = TILES_X * TILE  # 24
    hall_d = TILES_Y * TILE  # 16

    # floor tiles, grid, tile centers
    for ix in range(TILES_X):
        for iy in range(TILES_Y):
            place("floor_tile_large.gltf.glb", ix * TILE + TILE / 2, iy * TILE + TILE / 2, 0.0)

    # perimeter walls (4m segments) - long walls run along X at y=0 and y=hall_d
    for ix in range(TILES_X):
        cx = ix * TILE + TILE / 2
        # y = 0 wall (south) - doorway at the first segment (entrance)
        if ix == 0:
            place("wall_doorway.glb", cx, 0.0, 0.0, rot_z_deg=0)
        else:
            place("wall.gltf.glb", cx, 0.0, 0.0, rot_z_deg=0)
        # y = hall_d wall (north, solid) - the boss end's long side
        place("wall.gltf.glb", cx, hall_d, 0.0, rot_z_deg=180)

    for iy in range(TILES_Y):
        cy = iy * TILE + TILE / 2
        place("wall.gltf.glb", 0.0, cy, 0.0, rot_z_deg=90)  # west (entrance) end
        place("wall.gltf.glb", hall_w, cy, 0.0, rot_z_deg=-90)  # east (boss) end

    # corner columns for a finished look at the 4 corners
    for (cx, cy) in [(0, 0), (hall_w, 0), (0, hall_d), (hall_w, hall_d)]:
        place("pillar_decorated.gltf.glb", cx, cy, 0.0)

    # a row of interior pillars flanking the middle third (visual break between
    # the "wave 1/2" area and the boss chamber - MQ14/15/16 in docs/QUESTLINE_ACT1.md)
    mid_x = hall_w * 0.62
    place("pillar.gltf.glb", mid_x, TILE * 0.75, 0.0)
    place("pillar.gltf.glb", mid_x, hall_d - TILE * 0.75, 0.0)

    # mounted torches along the long walls for lighting flavor
    for ix in [1, 3, 5]:
        cx = ix * TILE
        place("torch_mounted.gltf.glb", cx, 0.15, 2.2, rot_z_deg=0)
        place("torch_mounted.gltf.glb", cx, hall_d - 0.15, 2.2, rot_z_deg=180)

    # entrance dressing
    place("crates_stacked.gltf.glb", TILE * 1.3, TILE * 0.6, 0.0, rot_z_deg=20)

    # boss chamber dressing at the far (east) end
    boss_x = hall_w - TILE * 1.2
    boss_y = hall_d / 2
    place("rubble_large.gltf.glb", boss_x - 1.5, boss_y + 2.0, 0.0)
    place("chest_gold.glb", boss_x, boss_y - 2.5, 0.0, rot_z_deg=-90)
    place("banner_shield_red.gltf.glb", hall_w - 0.3, boss_y, 2.5, rot_z_deg=90)

    bpy.ops.object.select_all(action="SELECT")
    bpy.context.view_layer.objects.active = bpy.context.selected_objects[0]
    os.makedirs(os.path.dirname(ENV_OUT), exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=ENV_OUT, export_format="GLB")
    print("WROTE", ENV_OUT)


def build_navmesh():
    clear_scene()
    hall_w = TILES_X * TILE
    hall_d = TILES_Y * TILE
    # single flat plane covering the walkable interior, inset slightly from the walls
    inset = 0.6
    bpy.ops.mesh.primitive_plane_add(size=1.0, location=(hall_w / 2, hall_d / 2, 0.05))
    plane = bpy.context.active_object
    plane.name = "navmesh"
    plane.scale = ((hall_w - inset * 2) / 2.0, (hall_d - inset * 2) / 2.0, 1.0)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    os.makedirs(os.path.dirname(NAVMESH_OUT), exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=NAVMESH_OUT, export_format="GLB")
    print("WROTE", NAVMESH_OUT)


build_environment()
build_navmesh()
