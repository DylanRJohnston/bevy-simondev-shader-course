use bevy::{
    prelude::*,
    render::{
        render_resource::{AsBindGroup, ShaderRef},
        texture::{ImageAddressMode, ImageLoaderSettings, ImageSampler, ImageSamplerDescriptor},
    },
};
use shaders::{ExamplePlugin, SpawnMaterial};

pub fn main() {
    let mut app = App::new();
    app.add_plugins(ExamplePlugin::<CustomMaterial>::default());
    app.add_systems(Startup, spawn_material);
    app.run();
}

#[derive(Asset, TypePath, AsBindGroup, Debug, Clone)]
struct CustomMaterial {
    #[uniform(0)]
    first: LinearRgba,

    #[texture(1)]
    #[sampler(2)]
    texture: Handle<Image>,
}

const SHADER_ASSET_PATH: &str = "shaders/chromatic_aberration.wgsl";

impl Material for CustomMaterial {
    fn fragment_shader() -> ShaderRef {
        SHADER_ASSET_PATH.into()
    }
}

fn spawn_material(mut commands: Commands, asset_server: Res<AssetServer>) {
    commands.trigger(SpawnMaterial {
        material: CustomMaterial {
            first: LinearRgba::RED,
            texture: asset_server.load_with_settings("textures/dog.jpg", |s: &mut _| {
                *s = ImageLoaderSettings {
                    sampler: ImageSampler::Descriptor(ImageSamplerDescriptor {
                        address_mode_u: ImageAddressMode::Repeat,
                        address_mode_v: ImageAddressMode::Repeat,
                        ..default()
                    }),
                    ..default()
                }
            }),
        },
    });
}
