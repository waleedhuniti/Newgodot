extends SceneTree

# Run once after a fresh asset import, before exporting to web:
#   godot3 --path . -s tools/optimize_dungeon_textures.gd
#
# dungeon_01.glb's importer (Godot 3.x's glTF scene importer, materials/storage=1)
# extracts each material into its own res://assets/environments/dungeon_01/*.material
# file, embedding its albedo texture as *uncompressed* raw RGBA8 - 1024x1024 means
# each file is ~4MB, and there are 60 of them (~250MB total). Godot 3.x's scene
# importer has no texture-compression option for these (unlike standalone texture
# files, which the "VRAM Texture Compression" export setting does cover), and the
# result was originally too large to host at all (see docs/TECHNICAL_PLAN.md §7).
# This is a stylized low-poly dungeon, so 256x256 loses nothing visible and cuts
# the folder from ~250MB to ~17MB.

func _init():
	var dir = Directory.new()
	dir.open("res://assets/environments/dungeon_01")
	dir.list_dir_begin(true, true)
	var fname = dir.get_next()
	var count = 0
	while fname != "":
		if fname.ends_with(".material"):
			var path = "res://assets/environments/dungeon_01/" + fname
			var mat = load(path)
			if mat is SpatialMaterial and mat.albedo_texture:
				var img = mat.albedo_texture.get_data()
				img.resize(256, 256, Image.INTERPOLATE_LANCZOS)
				var new_tex = ImageTexture.new()
				new_tex.create_from_image(img, 0)
				mat.albedo_texture = new_tex
				ResourceSaver.save(path, mat)
				count += 1
		fname = dir.get_next()
	print("Resized ", count, " materials")
	quit()
