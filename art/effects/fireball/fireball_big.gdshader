shader_type spatial;
render_mode unshaded,depth_draw_alpha_prepass;

// Ported the same way as fireball_core.gdshader - see its comment.
uniform sampler2D noise1;
uniform vec4 color : hint_color;
uniform vec4 overlayColor : hint_color;

void vertex() {
	VERTEX += 0.3 * NORMAL * texture(noise1, UV + vec2(0.5 * TIME, 0.2 * TIME)).r;
}

void fragment() {
	ALBEDO = color.rgb;
	float mixAmount = texture(noise1, UV + vec2(-0.35 * TIME, 0.7 * TIME)).r - 0.2;
	mixAmount = smoothstep(0.3, 0.7, mixAmount);
	ALBEDO = mix(ALBEDO, overlayColor.rgb, 1.45 * mixAmount);
	ALPHA = mixAmount + 0.55;
}
