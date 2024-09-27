#import bevy_pbr::{
  mesh_functions,
  mesh_view_bindings::globals,
  forward_io::{Vertex, VertexOutput},
  view_transformations::position_world_to_clip,
};

@group(2) @binding(0) var<uniform> first: vec4f;
@group(2) @binding(1) var material_texture: texture_2d<f32>;
@group(2) @binding(2) var material_sampler: sampler;

@fragment
fn fragment(mesh: VertexOutput) -> @location(0) vec4f {
  var uv = mesh.uv * -2.0;

  var rColor = textureSample(material_texture, material_sampler, uv);
  var gColor = textureSample(material_texture, material_sampler, uv + vec2(0.01, 0.0));
  var bColor = textureSample(material_texture, material_sampler, uv + vec2(0.0, 0.01));

  return vec4f(rColor.r, gColor.g, bColor.b, 1.0);
}