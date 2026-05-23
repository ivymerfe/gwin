package cpu_shader

import "core:math"
import "core:math/linalg/hlsl"

RenderInfo :: struct {
	time:   f32,
	width:  int,
	height: int,
}

palette :: #force_inline proc(t: hlsl.float) -> hlsl.float3 {
	a := hlsl.float3{0, 0, 0}
	b := hlsl.float3{0.5, 0.5, 0.5}
	c := hlsl.float3{0.5, 1.0, 1.0}
	d := hlsl.float3{0.5, 0.4, 0.3}
	return a + b * hlsl.cos(2 * math.PI * (c * t + d))
}

dist :: #force_inline proc(sin_ps, cos_ps_zxy: hlsl.float3, s: hlsl.float) -> hlsl.float {
	return hlsl.abs(hlsl.dot(sin_ps, cos_ps_zxy) + 2) / s
}

shader :: proc(uv: hlsl.float2, time: hlsl.float) -> hlsl.float3 {
	dir := hlsl.normalize(hlsl.float3{uv.x, uv.y, 0.5})
	pos := hlsl.float3{0, 0, time * 0.1}
	color := hlsl.float3{}
	t: hlsl.float = -1.0

	for i in 0 ..< 8 {
		p1 := pos + dir * t

		s1 := hlsl.sin(p1)
		c1 := hlsl.cos(p1)

		s2 := 2 * s1 * c1
		c2 := c1 * c1 - s1 * s1

		s4 := 2 * s2 * c2
		c4 := c2 * c2 - s2 * s2

		d := hlsl.abs(dist(s1, c1.zxy, 1.) - dist(s2, c2.zxy, 2.) - dist(s4, c4.zxy, 4.))
		d += 0.02
		color += palette(t) / d
		t += d + 0.4
	}
	return hlsl.saturate(hlsl.tanh(color / 40))
}

render :: proc(buffer: [^]u32, info: RenderInfo) {
	width := info.width
	height := info.height
	wf, hf := f32(width), f32(height)

	for y := 0; y < height; y += 1 {
		yf := f32(y) / hf - 0.5
		for x := 0; x < width; x += 1 {
			xf := f32(x) / hf - 0.5
			uv := hlsl.float2{xf, yf}
			col := shader(uv, info.time)
			r: u32 = u32(math.floor(col[0] * 256.0))
			g: u32 = u32(math.floor(col[1] * 256.0))
			b: u32 = u32(math.floor(col[2] * 256.0))
			xrgb := (r << 16) + (g << 8) + b
			buffer[y * width + x] = xrgb
		}
	}
}

