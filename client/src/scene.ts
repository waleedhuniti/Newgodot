import * as THREE from "three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";

// Placeholder world: a flat ground plane stands in for a real map model.
// Monster models are real (Quaternius Animated Monster Pack, CC0 — see
// art/creatures/quaternius-animated-monster-pack/), placed at fixed spawn
// points until a real wild-spawn system exists.
const MONSTER_SPAWNS: { model: string; idleClip: string; position: THREE.Vector3 }[] = [
  { model: "/models/Dragon.glb", idleClip: "Dragon_Flying", position: new THREE.Vector3(6, 0, 4) },
  { model: "/models/Bat.glb", idleClip: "Bat_Flying", position: new THREE.Vector3(-8, 0, 6) },
  { model: "/models/Skeleton.glb", idleClip: "Skeleton_Idle", position: new THREE.Vector3(3, 0, -10) },
  { model: "/models/Slime.glb", idleClip: "Slime_Idle", position: new THREE.Vector3(-5, 0, -6) },
];

export class GameWorld {
  scene = new THREE.Scene();
  camera: THREE.PerspectiveCamera;
  renderer: THREE.WebGLRenderer;

  private playerMeshes = new Map<string, THREE.Mesh>();
  private localSessionId: string | null = null;
  private mixers: THREE.AnimationMixer[] = [];
  private clock = new THREE.Clock();
  private loader = new GLTFLoader();

  constructor(canvas: HTMLCanvasElement) {
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.renderer.setSize(window.innerWidth, window.innerHeight);

    this.scene.background = new THREE.Color(0x1a1a26);
    this.scene.fog = new THREE.Fog(0x1a1a26, 20, 60);

    this.camera = new THREE.PerspectiveCamera(65, window.innerWidth / window.innerHeight, 0.1, 500);
    this.camera.position.set(0, 6, 10);

    this.setupLights();
    this.setupGround();
    this.setupMonsterMarkers();

    window.addEventListener("resize", () => this.onResize());
  }

  private setupLights() {
    const sun = new THREE.DirectionalLight(0xffffff, 2.0);
    sun.position.set(10, 20, 10);
    this.scene.add(sun);
    this.scene.add(new THREE.AmbientLight(0x556677, 1.2));
  }

  private setupGround() {
    const ground = new THREE.Mesh(
      new THREE.PlaneGeometry(120, 120),
      new THREE.MeshStandardMaterial({ color: 0x2c3b2c })
    );
    ground.rotation.x = -Math.PI / 2;
    this.scene.add(ground);

    const grid = new THREE.GridHelper(120, 60, 0x445544, 0x334433);
    this.scene.add(grid);
  }

  private setupMonsterMarkers() {
    for (const spawn of MONSTER_SPAWNS) {
      this.loader.load(
        spawn.model,
        (gltf) => {
          const model = gltf.scene;
          model.position.copy(spawn.position);
          this.scene.add(model);

          if (gltf.animations.length > 0) {
            const mixer = new THREE.AnimationMixer(model);
            const clip =
              gltf.animations.find((c) => c.name.endsWith(spawn.idleClip)) ?? gltf.animations[0];
            mixer.clipAction(clip).play();
            this.mixers.push(mixer);
          }
        },
        undefined,
        (err) => console.error(`failed to load ${spawn.model}`, err)
      );
    }
  }

  setLocalSessionId(id: string) {
    this.localSessionId = id;
  }

  upsertPlayer(sessionId: string, x: number, y: number, z: number) {
    let mesh = this.playerMeshes.get(sessionId);
    if (!mesh) {
      const isLocal = sessionId === this.localSessionId;
      const geo = new THREE.CapsuleGeometry(0.4, 1.0, 4, 8);
      const mat = new THREE.MeshStandardMaterial({ color: isLocal ? 0x4da6ff : 0xffb84d });
      mesh = new THREE.Mesh(geo, mat);
      this.scene.add(mesh);
      this.playerMeshes.set(sessionId, mesh);
    }
    mesh.position.set(x, y + 0.9, z);
  }

  removePlayer(sessionId: string) {
    const mesh = this.playerMeshes.get(sessionId);
    if (mesh) {
      this.scene.remove(mesh);
      this.playerMeshes.delete(sessionId);
    }
  }

  followCamera(x: number, y: number, z: number) {
    this.camera.position.set(x, y + 5, z + 8);
    this.camera.lookAt(x, y + 1, z);
  }

  private onResize() {
    this.camera.aspect = window.innerWidth / window.innerHeight;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(window.innerWidth, window.innerHeight);
  }

  render() {
    const dt = this.clock.getDelta();
    for (const mixer of this.mixers) mixer.update(dt);
    this.renderer.render(this.scene, this.camera);
  }
}
