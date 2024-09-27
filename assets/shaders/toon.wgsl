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

  // Toon Diffuse
  var intensity =  max(0.0, dot(light_dir, normal));
  intensity *= smoothstep(0.5, 0.505, intensity);

  let diffuse = light_color * intensity;

  // Phong specular
  let view_dir = normalize(view.world_position - mesh.world_position.xyz);
  let r = normalize(reflect(-light_dir, normal));
  
  // Toon Specular
  var phong_value = pow(max(0.0, dot(view_dir, r)), 32.0);
  phong_value = smoothstep(0.5, 0.51, phong_value);

  let specular = vec3(phong_value);

  let color = ambient + 0.01 * hemi_light + 0.5 * diffuse + specular;
  
  return vec4f(linear_to_srgb(color), 1.0);
}