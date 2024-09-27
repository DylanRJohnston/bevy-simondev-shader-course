use bevy::{
    core_pipeline::Skybox,
    math::VectorSpace,
    prelude::*,
    render::render_resource::{AsBindGroup, ShaderRef},
};
use bevy_panorbit_camera::{PanOrbitCamera, PanOrbitCameraPlugin};
use shaders::{ExamplePlugin, SpawnMaterial};

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
struct CustomMaterial {
    #[texture(0, dimension = "cube")]
    #[sampler(1)]
    texture: Handle<Image>,
}

const SHADER_ASSET_PATH: &str = "shaders/ibl_specular.wgsl";

impl Material for CustomMaterial {
    fn fragment_shader() -> ShaderRef {
        SHADER_ASSET_PATH.into()
    }
}

#[derive(Resource, Deref)]
struct SkyboxHandle(Handle<Image>);

fn setup(asset_server: Res<AssetServer>, mut commands: Commands) {
    let scene = asset_server.load("models/suzanne.gltf#Scene0");

    commands.spawn(SceneBundle { scene, ..default() });

    let skybox = asset_server.load("textures/Ryfjallet_cubemap_astc4x4.ktx2");
    commands.spawn((
        Camera3dBundle {
            transform: Transform::from_translation(Vec3::new(1.5, 1.5, 3.0))
                .looking_at(Vec3::ZERO, Vec3::Y),

            ..default()
        },
        PanOrbitCamera::default(),
        Skybox {
            image: skybox.clone(),
            brightness: 500.,
        },
    ));

    commands.insert_resource(SkyboxHandle(skybox));
}

fn override_material(
    models: Query<Entity, Added<Handle<StandardMaterial>>>,
    skybox: Res<SkyboxHandle>,
    mut materials: ResMut<Assets<CustomMaterial>>,
    mut commands: Commands,
) {
    for model in &models {
        let material = materials.add(CustomMaterial {
            texture: skybox.clone(),
        });

        commands
            .entity(model)
            .remove::<Handle<StandardMaterial>>()
            .insert(material);
    }
}
