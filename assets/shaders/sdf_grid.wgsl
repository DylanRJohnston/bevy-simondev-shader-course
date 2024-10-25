#import bevy_pbr::{
  mesh_functions,
  mesh_view_bindings::globals,
  forward_io::{Vertex, VertexOutput},
  view_transformations::position_world_to_clip,
};

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

@fragment
fn fragment(
  mesh: VertexOutput
) -> @location(0) vec4f { 
  let pixel_coords = mesh.position.xy;

  var color = vec3(0.0);
  color = background_color(mesh.uv);
  color = draw_grid(pixel_coords, color, vec3(0.5), 20.0, 1.0);
  color = draw_grid(pixel_coords, color, vec3(0.0), 200.0, 2.0);

  return vec4(color, 1.0);
}