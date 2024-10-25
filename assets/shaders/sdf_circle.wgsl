#import bevy_pbr::{
  mesh_functions,
  mesh_view_bindings::globals,
  forward_io::{Vertex, VertexOutput},
  view_transformations::position_world_to_clip,
};

@group(2) @binding(0) var<uniform> screen_resolution: vec2f;

fn remap(value: f32, prev_low: f32, prev_high: f32, low: f32, high: f32) -> f32 {
  return low + high * (value - prev_low) / (prev_high - prev_low);
}

fn background_color(uv: vec2f) -> vec3f {
  let dist_from_center = length(abs(uv - vec2f(0.5)));
  
  var vignette = 1.0 - dist_from_center;
  vignette = smoothstep(0.0, 0.7, vignette);
  vignette = remap(vignette, 0.0, 1.0, 0.3, 1.0);

  return vec3(vignette);
}

fn draw_grid(
  position: vec2f,
  color: vec3f,
  line_color: vec3f,
  cell_spacing: f32,
  line_width: f32,
) -> vec3f {
  let cells = abs(fract(position / vec2(cell_spacing)) - 0.5);
  let dist_to_edge = (0.5 - max(cells.x, cells.y)) * cell_spacing;
  let lines = smoothstep(0.0, line_width, dist_to_edge);

  return mix(line_color, color, lines);
}

fn sdf_circle(point: vec2f, radius: f32) -> f32 {
  return length(point) - radius;
}

fn sdf_line(point: vec2f, start: vec2f, finish: vec2f) -> f32 {
  let distance = point - start;
  let direction = finish - start;

  let len = clamp(dot(distance, direction) / dot(direction, direction), 0.0, 1.0);

  return length(distance - direction * len);
}

fn sdf_box(point: vec2f, bounds: vec2f) -> f32 {
  let distance = abs(point) - bounds;
  return length(max(distance, vec2f(0.0, 0.0))) + min(max(distance.x, distance.y), 0.0);
}

fn translate(point: vec2f, offset: vec2f) -> vec2f {
  return point - offset;
}

fn rotate(point: vec2f, amount: f32) -> vec2f {
  return vec2(
    point.x * cos(amount) - point.y * sin(amount),
    point.x * sin(amount) + point.y * cos(amount)
  );
}

fn sdf_union(a: f32, b: f32) -> f32 {
  return min(a, b);
}

fn sdf_soft_union(a: f32, b: f32, k: f32) -> f32 {
  return -log(exp(k * -a) + exp(k * -b)) / k;
}

fn sdf_soft_intersection(a: f32, b: f32, k: f32) -> f32 {
  return log(exp(k * a) + exp(k * b)) / k;
}

@fragment
fn fragment(
  mesh: VertexOutput
) -> @location(0) vec4f { 
  var pixel_coords = mesh.position.xy;
  pixel_coords.x = remap(pixel_coords.x, 0.0, screen_resolution.x / 2.0, -screen_resolution.x / 2.0, screen_resolution.x / 2.0);
  pixel_coords.y = remap(pixel_coords.y, 0.0, screen_resolution.y / 2.0, screen_resolution.y / 2.0, -screen_resolution.y / 2.0);

  var color = vec3(0.0);
  color = background_color(mesh.uv);
  color = draw_grid(pixel_coords, color, vec3(0.5), 10.0, 1.0);
  color = draw_grid(pixel_coords, color, vec3(0.0), 100.0, 2.0);

  let box = sdf_box(rotate(translate(pixel_coords, vec2f(0.0, -50.)), globals.time), vec2(300.0, 100.0));

  let d1 = sdf_circle(translate(pixel_coords, vec2f(-300.0, -150.0)), 150.0);
  let d2 = sdf_circle(translate(pixel_coords, vec2f(300.0, -150.0)), 150.0);
  let d3 = sdf_circle(translate(pixel_coords, vec2f(0.0, 200.0)), 150.0);

  let d = sdf_soft_union(box, sdf_union(sdf_union(d1, d2), d3), 0.05);

  color = mix(vec3f(0.1, 0.0, 0.0), color, smoothstep(-1.0, 1.0, d));
  color = mix(vec3f(1.0, 0.0, 0.0), color, smoothstep(-5.0, 0.0, d));

  // let distance = sdf_line(pixel_coords, vec2(-100.0, -50.0), vec2(200.0, -75.0));
  // color = mix(vec3f(1.0, 0.0, 0.0), color, step(5.0, distance));

  // let distance = sdf_box(pixel_coords, vec2(300.0, 100.0));
  // color = mix(vec3f(1.0, 0.0, 0.0), color, step(10., distance));

  return vec4(color, 1.0);
}