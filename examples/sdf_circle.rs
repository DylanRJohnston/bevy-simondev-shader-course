use bevy::{
    prelude::*,
    render::render_resource::{AsBindGroup, ShaderRef},
};
use shaders::{ExamplePlugin, MaterialHandle, SpawnMaterial};

pub fn main() {
    let mut app = App::new();
    app.add_plugins(ExamplePlugin::<CustomMaterial>::default());
    app.add_systems(Startup, spawn_material);
    app.add_systems(Update, update_resolution);
    app.run();
}

#[derive(Asset, TypePath, AsBindGroup, Debug, Clone)]
struct CustomMaterial {
    #[uniform(0)]
    screen_resolution: Vec2,
}

const SHADER_ASSET_PATH: &str = "shaders/sdf_circle.wgsl";

impl Material for CustomMaterial {
    fn fragment_shader() -> ShaderRef {
        SHADER_ASSET_PATH.into()
    }
}

fn spawn_material(windows: Query<&Window>, mut commands: Commands) {
    let resolution = &windows.get_single().unwrap().resolution;

    commands.trigger(SpawnMaterial {
        material: CustomMaterial {
            screen_resolution: Vec2::new(
                resolution.physical_width() as f32,
                resolution.physical_height() as f32,
            ),
        },
    });
}

fn update_resolution(
    windows: Query<&Window>,
    handle: Res<MaterialHandle<CustomMaterial>>,
    mut materials: ResMut<Assets<CustomMaterial>>,
) {
    let resolution = &windows.get_single().unwrap().resolution;

    let material = materials.get_mut(&handle.id).unwrap();

    material.screen_resolution = Vec2::new(
        resolution.physical_width() as f32,
        resolution.physical_height() as f32,
    );
}
