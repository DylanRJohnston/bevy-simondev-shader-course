use bevy::{prelude::*, render::camera::ScalingMode};
use std::{hash::Hash, marker::PhantomData};

#[derive(Event)]
pub struct SpawnMaterial<M> {
    pub material: M,
}

pub struct ExamplePlugin<M>(PhantomData<M>);

impl<M> Default for ExamplePlugin<M> {
    fn default() -> Self {
        Self(Default::default())
    }
}

impl<M: Material> Plugin for ExamplePlugin<M>
where
    M::Data: PartialEq + Eq + Hash + Clone,
{
    fn build(&self, app: &mut bevy::prelude::App) {
        app.add_plugins(DefaultPlugins);
        app.add_plugins(MaterialPlugin::<M>::default());
        app.observe(full_screen_quad::<M>);
    }
}

fn full_screen_quad<M: Material>(
    trigger: Trigger<SpawnMaterial<M>>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<M>>,
    mut commands: Commands,
) {
    let mesh = meshes.add(Mesh::from(Rectangle::from_size(Vec2::new(1.0, 1.0))));
    // let mesh = meshes.add(Mesh::from(Cuboid::from_size(Vec3::new(1.0, 1.0, 1.0))));
    let material = materials.add(trigger.event().material.clone());

    commands.spawn(MaterialMeshBundle {
        mesh,
        material,
        // transform:
        transform: Transform::default().looking_at(Vec3::new(0., -1., 0.), Vec3::Y),
        ..default()
    });

    commands.spawn(Camera3dBundle {
        projection: Projection::Orthographic(OrthographicProjection {
            // scaling_mode: ScalingMode::WindowSize(100.),
            scaling_mode: ScalingMode::Fixed {
                height: 1.0,
                width: 1.0,
            },
            ..default()
        }),
        transform: Transform::from_translation(Vec3::new(0., 1., 0.))
            .looking_at(Vec3::new(0.0, 0.0, 0.0), Vec3::Y),
        ..default()
    });
}
