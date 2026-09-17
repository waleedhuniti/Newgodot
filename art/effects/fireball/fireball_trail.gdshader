shader_type spatial;
render_mode cull_disabled,unshaded;

// Ported the same way as fireball_core.gdshader - see its comment.
uniform sampler2D noise1;
uniform vec4 color : hint_color;
uniform vec4 overlayColor : hint_color;

void fragment() {
	ALBEDO = color.rgb;
	float mixAmount = texture(noise1, vec2(UV.x, 0.25 * UV.y) + vec2(0, 0.55 * TIME)).r - 0.2;
	mixAmount = smoothstep(0.5, 0.9, mixAmount);
	ALBEDO = mix(ALBEDO, overlayColor.rgb, mixAmount);
	ALPHA = mixAmount;
}
