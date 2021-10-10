use crate::shader::{self, ShaderStage};

#[path = "../third_party/smaa/Textures/AreaTex.rs"]
mod area_tex;
use area_tex::*;

#[path = "../third_party/smaa/Textures/SearchTex.rs"]
mod search_tex;
use search_tex::*;

use wgpu::{util::DeviceExt, TextureView};

pub struct BindGroupLayouts {
    pub edge_detect_bind_group_layout: wgpu::BindGroupLayout,
    pub blend_weight_bind_group_layout: wgpu::BindGroupLayout,
    pub neighborhood_blending_bind_group_layout: wgpu::BindGroupLayout,
}
pub struct Pipelines {
    pub edge_detect: wgpu::RenderPipeline,
    pub blend_weight: wgpu::RenderPipeline,
    pub neighborhood_blending: wgpu::RenderPipeline,
}
pub struct Resources {
    pub area_texture: wgpu::Texture,
    pub search_texture: wgpu::Texture,
    pub linear_sampler: wgpu::Sampler,
}
pub struct Targets {
    pub rt_uniforms: wgpu::Buffer,
    pub edges_target: wgpu::TextureView,
    pub blend_target: wgpu::TextureView,
}
pub struct BindGroups {
    pub edge_detect_bind_group: wgpu::BindGroup,
    pub blend_weight_bind_group: wgpu::BindGroup,
    pub neighborhood_blending_bind_group: wgpu::BindGroup,
}

impl BindGroupLayouts {
    pub fn new(device: &wgpu::Device) -> Self {
        Self {
            edge_detect_bind_group_layout: device.create_bind_group_layout(
                &wgpu::BindGroupLayoutDescriptor {
                    label: Some("smaa.bind_group_layout.edge_detect"),
                    entries: &[
                        wgpu::BindGroupLayoutEntry {
                            binding: 0,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Sampler {
                                filtering: true,
                                comparison: false,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 1,
                            visibility: wgpu::ShaderStages::VERTEX | wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Buffer {
                                ty: wgpu::BufferBindingType::Uniform,
                                has_dynamic_offset: false,
                                min_binding_size: None,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 2,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Texture {
                                sample_type: wgpu::TextureSampleType::Float { filterable: true },
                                view_dimension: wgpu::TextureViewDimension::D2,
                                multisampled: false,
                            },
                            count: None,
                        },
                    ],
                },
            ),
            blend_weight_bind_group_layout: device.create_bind_group_layout(
                &wgpu::BindGroupLayoutDescriptor {
                    label: Some("smaa.bind_group_layout.blend_weight"),
                    entries: &[
                        wgpu::BindGroupLayoutEntry {
                            binding: 0,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Sampler {
                                filtering: true,
                                comparison: false,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 1,
                            visibility: wgpu::ShaderStages::VERTEX | wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Buffer {
                                ty: wgpu::BufferBindingType::Uniform,
                                has_dynamic_offset: false,
                                min_binding_size: None,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 2,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Texture {
                                sample_type: wgpu::TextureSampleType::Float { filterable: true },
                                view_dimension: wgpu::TextureViewDimension::D2,
                                multisampled: false,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 3,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Texture {
                                sample_type: wgpu::TextureSampleType::Float { filterable: true },
                                view_dimension: wgpu::TextureViewDimension::D2,
                                multisampled: false,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 4,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Texture {
                                sample_type: wgpu::TextureSampleType::Float { filterable: true },
                                view_dimension: wgpu::TextureViewDimension::D2,
                                multisampled: false,
                            },
                            count: None,
                        },
                    ],
                },
            ),
            neighborhood_blending_bind_group_layout: device.create_bind_group_layout(
                &wgpu::BindGroupLayoutDescriptor {
                    label: Some("smaa.bind_group_layout.neighborhood_blending"),
                    entries: &[
                        wgpu::BindGroupLayoutEntry {
                            binding: 0,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Sampler {
                                filtering: true,
                                comparison: false,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 1,
                            visibility: wgpu::ShaderStages::VERTEX | wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Buffer {
                                ty: wgpu::BufferBindingType::Uniform,
                                has_dynamic_offset: false,
                                min_binding_size: None,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 2,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Texture {
                                sample_type: wgpu::TextureSampleType::Float { filterable: true },
                                view_dimension: wgpu::TextureViewDimension::D2,
                                multisampled: false,
                            },
                            count: None,
                        },
                        wgpu::BindGroupLayoutEntry {
                            binding: 3,
                            visibility: wgpu::ShaderStages::FRAGMENT,
                            ty: wgpu::BindingType::Texture {
                                sample_type: wgpu::TextureSampleType::Float { filterable: true },
                                view_dimension: wgpu::TextureViewDimension::D2,
                                multisampled: false,
                            },
                            count: None,
                        },
                    ],
                },
            ),
        }
    }
}

impl Pipelines {
    pub fn new(
        device: &wgpu::Device,
        format: wgpu::TextureFormat,
        layouts: &BindGroupLayouts,
    ) -> Self {
        let quality = shader::ShaderQuality::High;
        let edge_detect_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("smaa.pipeline_layout.edge_detect"),
            bind_group_layouts: &[&layouts.edge_detect_bind_group_layout],
            push_constant_ranges: &[],
        });
        let edge_detect_shader_vert = wgpu::VertexState {
            module: &shader::get_shader(
                ShaderStage::EdgeDetectionVS,
                quality,
                "smaa.shader.edge_detect.vert",
                device,
            ),
            entry_point: "main",
            buffers: &[],
        };
        let edge_detect_shader_frag = wgpu::FragmentState {
            module: &shader::get_shader(
                ShaderStage::LumaEdgeDetectionPS,
                quality,
                "smaa.shader.edge_detect.frag",
                device,
            ),
            entry_point: "main",
            targets: &[wgpu::ColorTargetState {
                format: wgpu::TextureFormat::Rg8Unorm,
                blend: Some(wgpu::BlendState {
                    color: wgpu::BlendComponent::REPLACE,
                    alpha: wgpu::BlendComponent::REPLACE,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            }],
        };
        let edge_detect = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("smaa.pipeline.edge_detect"),
            layout: Some(&edge_detect_layout),
            vertex: edge_detect_shader_vert,
            fragment: Some(edge_detect_shader_frag),
            primitive: Default::default(),
            multisample: Default::default(),
            depth_stencil: None,
        });

        let blend_weight_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("smaa.pipeline_layout.blend_weight"),
            bind_group_layouts: &[&layouts.blend_weight_bind_group_layout],
            push_constant_ranges: &[],
        });
        let blend_weight_shader_vert = wgpu::VertexState {
            module: &shader::get_shader(
                ShaderStage::BlendingWeightVS,
                quality,
                "smaa.shader.blending_weight.vert",
                device,
            ),
            entry_point: "main",
            buffers: &[],
        };
        let blend_weight_shader_frag = wgpu::FragmentState {
            module: &shader::get_shader(
                ShaderStage::BlendingWeightPS,
                quality,
                "smaa.shader.blending_weight.frag",
                device,
            ),
            entry_point: "main",
            targets: &[wgpu::ColorTargetState {
                format: wgpu::TextureFormat::Rgba8Unorm,
                blend: Some(wgpu::BlendState {
                    color: wgpu::BlendComponent::REPLACE,
                    alpha: wgpu::BlendComponent::REPLACE,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            }],
        };
        let blend_weight = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("smaa.pipeline.blend_weight"),
            layout: Some(&blend_weight_layout),
            vertex: blend_weight_shader_vert,
            fragment: Some(blend_weight_shader_frag),
            primitive: Default::default(),
            multisample: Default::default(),
            depth_stencil: None,
        });

        let neighborhood_blending_layout =
            device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                label: Some("smaa.pipeline_layout.neighborhood_blending"),
                bind_group_layouts: &[&layouts.neighborhood_blending_bind_group_layout],
                push_constant_ranges: &[],
            });
        let neighborhood_blending_vert = wgpu::VertexState {
            module: &shader::get_shader(
                ShaderStage::NeighborhoodBlendingVS,
                quality,
                "smaa.shader.neighborhood_blending.vert",
                device,
            ),
            entry_point: "main",
            buffers: &[],
        };
        let neighborhood_blending_frag = wgpu::FragmentState {
            module: &shader::get_shader(
                ShaderStage::NeighborhoodBlendingPS,
                quality,
                "smaa.shader.neighborhood_blending.frag",
                device,
            ),
            entry_point: "main",
            targets: &[wgpu::ColorTargetState {
                format,
                blend: Some(wgpu::BlendState {
                    color: wgpu::BlendComponent::REPLACE,
                    alpha: wgpu::BlendComponent::REPLACE,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            }],
        };
        let neighborhood_blending =
            device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
                label: Some("smaa.pipeline.neighborhood_blending"),
                layout: Some(&neighborhood_blending_layout),
                vertex: neighborhood_blending_vert,
                fragment: Some(neighborhood_blending_frag),
                primitive: Default::default(),
                multisample: Default::default(),
                depth_stencil: None,
            });

        Self {
            edge_detect,
            blend_weight,
            neighborhood_blending,
        }
    }
}
impl Targets {
    pub fn new(device: &wgpu::Device, width: u32, height: u32) -> Self {
        let size = wgpu::Extent3d {
            width,
            height,
            depth_or_array_layers: 1,
        };
        let texture_desc = wgpu::TextureDescriptor {
            size,
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8Unorm,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::TEXTURE_BINDING,
            label: None,
        };

        let mut uniform_data = Vec::new();
        for f in &[
            1.0 / width as f32,
            1.0 / height as f32,
            width as f32,
            height as f32,
        ] {
            uniform_data.extend_from_slice(&f.to_ne_bytes());
        }
        let rt_uniforms = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("smaa.uniforms"),
            usage: wgpu::BufferUsages::UNIFORM,
            contents: &uniform_data,
        });

        Self {
            rt_uniforms,
            edges_target: device
                .create_texture(&wgpu::TextureDescriptor {
                    format: wgpu::TextureFormat::Rg8Unorm,
                    label: Some("smaa.texture.edge_target"),
                    ..texture_desc
                })
                .create_view(&wgpu::TextureViewDescriptor {
                    label: Some("smaa.texture_view.edge_target"),
                    ..Default::default()
                }),

            blend_target: device
                .create_texture(&wgpu::TextureDescriptor {
                    format: wgpu::TextureFormat::Rgba8Unorm,
                    label: Some("smaa.texture.blend_target"),
                    ..texture_desc
                })
                .create_view(&wgpu::TextureViewDescriptor {
                    label: Some("smaa.texture_view.blend_target"),
                    ..Default::default()
                }),
        }
    }
}
impl Resources {
    pub fn new(device: &wgpu::Device, queue: &wgpu::Queue) -> Self {
        let area_texture = device.create_texture_with_data(
            &queue,
            &wgpu::TextureDescriptor {
                label: Some("smaa.texture.area"),
                size: wgpu::Extent3d {
                    width: AREATEX_WIDTH,
                    height: AREATEX_HEIGHT,
                    depth_or_array_layers: 1,
                },
                mip_level_count: 1,
                sample_count: 1,
                dimension: wgpu::TextureDimension::D2,
                format: wgpu::TextureFormat::Rg8Unorm,
                usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            },
            &AREATEX_BYTES,
        );

        let search_texture = device.create_texture_with_data(
            &queue,
            &wgpu::TextureDescriptor {
                label: Some("smaa.texture.search"),
                size: wgpu::Extent3d {
                    width: SEARCHTEX_WIDTH,
                    height: SEARCHTEX_HEIGHT,
                    depth_or_array_layers: 1,
                },
                mip_level_count: 1,
                sample_count: 1,
                dimension: wgpu::TextureDimension::D2,
                format: wgpu::TextureFormat::R8Unorm,
                usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            },
            &SEARCHTEX_BYTES,
        );

        let linear_sampler = device.create_sampler(&wgpu::SamplerDescriptor {
            label: Some("smaa.sampler"),
            mag_filter: wgpu::FilterMode::Linear,
            min_filter: wgpu::FilterMode::Linear,
            mipmap_filter: wgpu::FilterMode::Nearest,
            address_mode_u: wgpu::AddressMode::ClampToEdge,
            address_mode_v: wgpu::AddressMode::ClampToEdge,
            ..Default::default()
        });

        Self {
            area_texture,
            search_texture,
            linear_sampler,
        }
    }
}

impl BindGroups {
    pub fn new(
        device: &wgpu::Device,
        layouts: &BindGroupLayouts,
        resources: &Resources,
        targets: &Targets,
        color_target: &TextureView,
    ) -> Self {
        Self {
            edge_detect_bind_group: device.create_bind_group(&wgpu::BindGroupDescriptor {
                label: Some("smaa.bind_group.edge_detect"),
                layout: &layouts.edge_detect_bind_group_layout,
                entries: &[
                    wgpu::BindGroupEntry {
                        binding: 0,
                        resource: wgpu::BindingResource::Sampler(&resources.linear_sampler),
                    },
                    wgpu::BindGroupEntry {
                        binding: 1,
                        resource: wgpu::BindingResource::Buffer(wgpu::BufferBinding {
                            buffer: &targets.rt_uniforms,
                            offset: 0,
                            size: None,
                        }),
                    },
                    wgpu::BindGroupEntry {
                        binding: 2,
                        resource: wgpu::BindingResource::TextureView(color_target),
                    },
                ],
            }),

            blend_weight_bind_group: device.create_bind_group(&wgpu::BindGroupDescriptor {
                label: Some("smaa.bind_group.blend_weight"),
                layout: &layouts.blend_weight_bind_group_layout,
                entries: &[
                    wgpu::BindGroupEntry {
                        binding: 0,
                        resource: wgpu::BindingResource::Sampler(&resources.linear_sampler),
                    },
                    wgpu::BindGroupEntry {
                        binding: 1,
                        resource: wgpu::BindingResource::Buffer(wgpu::BufferBinding {
                            buffer: &targets.rt_uniforms,
                            offset: 0,
                            size: None,
                        }),
                    },
                    wgpu::BindGroupEntry {
                        binding: 2,
                        resource: wgpu::BindingResource::TextureView(&targets.edges_target),
                    },
                    wgpu::BindGroupEntry {
                        binding: 3,
                        resource: wgpu::BindingResource::TextureView(
                            &resources.area_texture.create_view(&Default::default()),
                        ),
                    },
                    wgpu::BindGroupEntry {
                        binding: 4,
                        resource: wgpu::BindingResource::TextureView(
                            &resources.search_texture.create_view(&Default::default()),
                        ),
                    },
                ],
            }),
            neighborhood_blending_bind_group: device.create_bind_group(
                &wgpu::BindGroupDescriptor {
                    label: Some("smaa.bind_group.neighborhood_blending"),
                    layout: &layouts.neighborhood_blending_bind_group_layout,
                    entries: &[
                        wgpu::BindGroupEntry {
                            binding: 0,
                            resource: wgpu::BindingResource::Sampler(&resources.linear_sampler),
                        },
                        wgpu::BindGroupEntry {
                            binding: 1,
                            resource: wgpu::BindingResource::Buffer(wgpu::BufferBinding {
                                buffer: &targets.rt_uniforms,
                                offset: 0,
                                size: None,
                            }),
                        },
                        wgpu::BindGroupEntry {
                            binding: 2,
                            resource: wgpu::BindingResource::TextureView(color_target),
                        },
                        wgpu::BindGroupEntry {
                            binding: 3,
                            resource: wgpu::BindingResource::TextureView(&targets.blend_target),
                        },
                    ],
                },
            ),
        }
    }
}
