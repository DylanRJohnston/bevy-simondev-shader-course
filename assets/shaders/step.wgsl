#import bevy_pbr::{
  mesh_functions,
  mesh_view_bindings::globals,
  forward_io::{Vertex, VertexOutput},
  view_transformations::position_world_to_clip,
};

@fragment
fn fragment(mesh: VertexOutput) -> @location(0) vec4f { 
  let u = mesh.uv.x;

  return vec4f(step(0.5, u));
}