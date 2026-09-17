shader_type spatial;
render_mode diffuse_toon,depth_draw_alpha_prepass;

// Ported from a provided Godot 4 fireball VFX asset - two renames needed:
// `hint_color` instead of Godot 4's `source_color`, and Godot 3.x's
// `depth_draw_alpha_prepass` render mode instead of 4.x's `depth_prepass_alpha`.
// Otherwise this shading language is close to identical between versions for
// basic spatial shaders.
uniform sampler2D noise1;
uniform vec4 color : hint_color;
uniform vec4 overlayColor : hint_color;

void vertex() {
	VERTEX += 0.3 * NORMAL * texture(noise1, UV + vec2(0, TIME)).r;
}

void fragment() {
	ALBEDO = color.rgb;
	float mixAmount = texture(noise1, UV + vec2(0.5 * TIME, 2.0 * TIME)).r - 0.2;
	mixAmount = smoothstep(0.3, 0.7, mixAmount);
	ALBEDO = mix(ALBEDO, overlayColor.rgb, 1.7 * mixAmount);
	ALPHA = 1.4 * mixAmount + 0.75;
}
