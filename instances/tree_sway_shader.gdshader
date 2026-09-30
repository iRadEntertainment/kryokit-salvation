shader_type spatial;
render_mode specular_disabled, depth_draw_opaque, cull_disabled;


uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;


uniform bool enable_billboard = true;


uniform float wind_speed : hint_range(0.0, 10.0) = 0.5;
uniform float wind_strength : hint_range(0.0, 2.0) = 0.25;
uniform float wind_scale : hint_range(0.0, 5.0) = .75;

void vertex() {

	if (enable_billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
			MODEL_MATRIX[3]
		);
	}


	float height_factor = 1.0 - UV.y;
	float world_offset = (NODE_POSITION_WORLD.x + NODE_POSITION_WORLD.z) * wind_scale;
	float wave = sin(TIME * wind_speed + world_offset);
	
	VERTEX.x += wave * wind_strength * height_factor;
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}