shader_type canvas_item;

uniform vec3 base_color : source_color = vec3(0.0, 0.02, 0.01);
uniform vec3 text_color : source_color = vec3(0.0, 0.8, 0.3);
uniform float scanline_speed = 0.02; // Slower
uniform float scanline_count = 80.0;
uniform float flicker_intensity = 0.005; // Much more subtle
uniform float jitter_intensity = 0.0005; // Almost static
uniform float grid_size = 50.0;
uniform vec2 world_offset = vec2(0.0);

// Random function
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Simple digit pattern (0 or 1)
float draw_bit(vec2 uv, float rnd) {
    uv = fract(uv);
    if (rnd < 0.5) { // Draw a '0'
        float d = length(uv - 0.5);
        return (d > 0.15 && d < 0.25) ? 1.0 : 0.0;
    } else { // Draw a '1'
        return (uv.x > 0.45 && uv.x < 0.55 && uv.y > 0.2 && uv.y < 0.8) ? 1.0 : 0.0;
    }
}

void fragment() {
    vec2 uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE;
    
    // Adjust UV for world movement
    vec2 world_uv = uv + (world_offset * SCREEN_PIXEL_SIZE);
    
    // 0. Jitter Effect (Very subtle)
    float jitter_time = floor(TIME * 8.0);
    vec2 jitter = vec2(random(vec2(jitter_time, 0.0)), random(vec2(0.0, jitter_time))) * 2.0 - 1.0;
    world_uv += jitter * jitter_intensity;
    
    // 1. Base Background
    vec3 final_color = base_color;
    
    // 2. The Digital Grid (Clusters/Blocks)
    vec2 grid_uv = world_uv * grid_size;
    grid_uv.x *= (1.0 / SCREEN_PIXEL_SIZE).x / (1.0 / SCREEN_PIXEL_SIZE).y;
    
    // Sub-grid lines for Agar.io feel
    vec2 sub_grid = fract(grid_uv);
    float grid_lines = smoothstep(0.02, 0.0, sub_grid.x) + smoothstep(0.98, 1.0, sub_grid.x) +
                       smoothstep(0.02, 0.0, sub_grid.y) + smoothstep(0.98, 1.0, sub_grid.y);
    final_color += text_color * grid_lines * 0.02;

    vec2 ipos = floor(grid_uv);
    vec2 fpos = fract(grid_uv);
    
    // Cluster Logic: bits only appear in grouped blocks
    vec2 block_pos = floor(grid_uv / 4.0); // 4x4 clusters
    float block_rnd = random(block_pos);
    
    if (block_rnd > 0.8) { // Only some 4x4 areas have bits
        float bit_rnd = random(ipos + floor(TIME * 0.05));
        float bit_val = draw_bit(fpos, bit_rnd);
        final_color += text_color * bit_val * 0.03;
    }
    
    // 3. Scanlines
    float scanline = sin(uv.y * scanline_count * 6.28 + TIME * scanline_speed * 100.0);
    scanline = smoothstep(0.4, 0.6, (scanline + 1.0) * 0.5);
    final_color -= vec3(scanline * 0.02);
    
    // 4. Large scrolling horizontal bands (CRT effect)
    float bands = sin(uv.y * 5.0 - TIME * 0.2);
    final_color += text_color * max(0.0, bands) * 0.02;
    
    // 5. Global Flicker
    float flicker = random(vec2(TIME, 0.0)) * flicker_intensity;
    final_color += vec3(flicker);
    
    // 6. Vignette
    float vignette = length(uv - 0.5);
    final_color *= (1.0 - vignette * 0.8);

    COLOR = vec4(final_color, 1.0);
}
