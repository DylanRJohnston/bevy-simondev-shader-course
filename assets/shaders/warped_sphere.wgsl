#import bevy_pbr::{
  mesh_functions,
  mesh_view_bindings::{view, globals},
  forward_io::{Vertex, VertexOutput},
  view_transformations::position_world_to_clip,
};

fn remap(value: f32, prev_low: f32, prev_high: f32, low: f32, high: f32) -> f32 {
  return low + high * (value - prev_low) / (prev_high - prev_low);
}

fn linear_to_srgb(value: vec3f) -> vec3f {
  let lt = value <= vec3(0.0031308);

  let v1 = value * 12.92;
  let v2 = pow(value, vec3(0.41666)) * 1.055 - vec3(0.055);

  return select(v2, v1, lt);
}

@vertex
fn vertex(vertex: Vertex) -> VertexOutput {
  var out: VertexOutput;

  let world_from_local = mesh_functions::get_world_from_local(vertex.instance_index);

  out.world_normal = mesh_functions::mesh_normal_local_to_world(vertex.normal, vertex.instance_index);
  out.world_position = mesh_functions::mesh_position_local_to_world(world_from_local, vec4f(vertex.position, 1.0));

  out.world_position.y += sin(globals.time + out.world_position.y);

  out.position = position_world_to_clip(out.world_position.xyz);
  out.uv = vertex.uv;

  return out;
}

@fragment
fn fragment(mesh: VertexOutput) -> @location(0) vec4f { 
  let ambient = vec3(0.00);
  let normal = normalize(mesh.world_normal);

  // Hemi Light
  let sky = vec3(0.0, 0.3, 0.6);
  let ground = vec3(0.6, 0.3, 0.1);

  let hemi_mix = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  let hemi_light = mix(ground, sky, hemi_mix);

  // Diffuse lighting
  let light_dir = normalize(vec3(1.0, 1.0, 1.0));
  let light_color = vec3(1.0, 1.0, 0.9);
  let diffuse = light_color * max(0.0, dot(light_dir, normal));

  // Phong specular
  let view_dir = normalize(view.world_position - mesh.world_position.xyz);
  let r = normalize(reflect(-light_dir, normal));
  let phong_value = pow(max(0.0, dot(view_dir, r)), 32.0);

  let specular = vec3(phong_value);

  let color = ambient + 0.01 * hemi_light + 0.5 * diffuse + specular;
  
  return vec4f(linear_to_srgb(color), 1.0);
}