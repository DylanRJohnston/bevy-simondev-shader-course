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
  let ambient = vec3(0.2);

  // Hemi Light
  let sky = vec3(0.0, 0.3, 0.6);
  let ground = vec3(0.6, 0.3, 0.1);

  let hemi_mix = remap(mesh.world_normal.y, -1.0, 1.0, 0.0, 1.0);
  let hemi_light = mix(ground, sky, hemi_mix);

  let color = ambient + hemi_light;
  
  return vec4f(color, 1.0);
}