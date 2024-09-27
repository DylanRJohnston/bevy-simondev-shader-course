#import bevy_pbr::{
  mesh_functions,
  mesh_view_bindings::globals,
  forward_io::{Vertex, VertexOutput},
  view_transformations::position_world_to_clip,
};

fn remap(value: f32, prev_low: f32, prev_high: f32, low: f32, high: f32) -> f32 {
  return low + high * (value - prev_low) / (prev_high - prev_low);
}

@fragment
fn fragment(mesh: VertexOutput) -> @location(0) vec4f { 
  let red = vec3(1.0, 0.0, 0.0);
  let blue = vec3(0.0, 0.0, 1.0);

  let t  = sin(globals.time);
  let color = mix(red, blue, remap(t, -1.0, 1.0, 0.0, 1.0));

  return vec4f(color, 0.0);
}