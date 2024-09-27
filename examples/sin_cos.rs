use bevy::{
    prelude::*,
    render::render_resource::{AsBindGroup, ShaderRef},
};
use shaders::{ExamplePlugin, SpawnMaterial};

pub fn main() {
    let mut app = App::new();
    app.add_plugins(ExamplePlugin::<CustomMaterial>::default());
    app.add_systems(Startup, spawn_material);
    app.run();
}

#[derive(Asset, TypePath, AsBindGroup, Debug, Clone)]
struct CustomMaterial {}

const SHADER_ASSET_PATH: &str = "shaders/sin_cos.wgsl";

impl Material for CustomMaterial {
    fn fragment_shader() -> ShaderRef {
        SHADER_ASSET_PATH.into()
    }
}

fn spawn_material(mut commands: Commands) {
    commands.trigger(SpawnMaterial {
        material: CustomMaterial {},
    });
}
