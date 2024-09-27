use bevy::{
    prelude::*,
    render::render_resource::{AsBindGroup, ShaderRef},
};
use bevy_panorbit_camera::{PanOrbitCamera, PanOrbitCameraPlugin};

pub fn main() {
    let mut app = App::new();
    app.add_plugins(DefaultPlugins);
    app.add_plugins(PanOrbitCameraPlugin);
    app.add_plugins(MaterialPlugin::<CustomMaterial>::default());
    app.add_systems(Startup, setup);
    app.add_systems(Update, override_material);
    app.insert_resource(ClearColor(Color::srgb(0.0, 0.0, 0.0)));
    app.run();
}

#[derive(Asset, TypePath, AsBindGroup, Debug, Clone)]
struct CustomMaterial {}

const SHADER_ASSET_PATH: &str = "shaders/custom_vertex.wgsl";

impl Material for CustomMaterial {
    fn fragment_shader() -> ShaderRef {
        SHADER_ASSET_PATH.into()
    }

    fn vertex_shader() -> ShaderRef {
        SHADER_ASSET_PATH.into()
    }
}

fn setup(asset_server: Res<AssetServer>, mut commands: Commands) {
    let scene = asset_server.load("models/suzanne.gltf#Scene0");

    commands.spawn(SceneBundle {
        scene,
        // transform: Transform::from_translation(Vec3::Y * -1.),
        ..default()
    });

    commands.spawn((
        Camera3dBundle {
            transform: Transform::from_translation(Vec3::new(1.5, 1.5, 3.0))
                .looking_at(Vec3::ZERO, Vec3::Y),

            ..default()
        },
        PanOrbitCamera::default(),
    ));
}

fn override_material(
    models: Query<Entity, Added<Handle<StandardMaterial>>>,
    mut materials: ResMut<Assets<CustomMaterial>>,
    mut commands: Commands,
) {
    for model in &models {
        let material = materials.add(CustomMaterial {});

        commands
            .entity(model)
            .remove::<Handle<StandardMaterial>>()
            .insert(material);
    }
}
