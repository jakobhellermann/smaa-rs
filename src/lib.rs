//! Post-process antialiasing for wgpu-rs, using the [SMAA reference implementation](https://github.com/iryoku/smaa).
//!
//! # Example
//!
//! ```
//! # use smaa::{SmaaMode, SmaaTarget};
//! # use winit::event::Event;
//! # use winit::event_loop::EventLoop;
//! # use winit::window::Window;
//! # fn main() { futures::executor::block_on(run()); }
//! # async fn run() -> Result<(), Box<dyn std::error::Error>> {
//! // Initialize wgpu
//! let event_loop = EventLoop::new();
//! let window = winit::window::Window::new(&event_loop).unwrap();
//! let instance = wgpu::Instance::new(wgpu::BackendBit::PRIMARY);
//! let surface = unsafe { instance.create_surface(&window) };
//! let adapter = instance.request_adapter(&Default::default()).await.unwrap();
//! let (device, queue) = adapter.request_device(&Default::default(), None).await?;
//! let swapchain_format = adapter.get_swap_chain_preferred_format(&surface)
//!     .unwrap_or(wgpu::TextureFormat::Bgra8UnormSrgb);
//! let mut swap_chain = device.create_swap_chain(&surface, &wgpu::SwapChainDescriptor {
//!     usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
//!     format: swapchain_format,
//!     width: window.inner_size().width,
//!     height: window.inner_size().height,
//!     present_mode: wgpu::PresentMode::Mailbox,
//! });
//!
//! // Create SMAA target
//! let mut smaa_target = SmaaTarget::new(
//!     &device,
//!     &queue,
//!     window.inner_size().width,
//!     window.inner_size().height,
//!     swapchain_format,
//!     SmaaMode::Smaa1X,
//! );
//!
//! // Main loop
//! event_loop.run(move |event, _, control_flow| {
//! #    *control_flow = winit::event_loop::ControlFlow::Exit;
//!     match event {
//!         Event::RedrawRequested(_) => {
//!             let output_frame = swap_chain.get_current_frame().unwrap().output;
//!             let frame = smaa_target.start_frame(&device, &queue, &output_frame.view);
//!
//!             // Render the scene into `*frame`.
//!             // [...]
//!         }
//!         _ => {}
//!     }
//! });
//! # }

mod shader;

/// Anti-aliasing mode. Higher values produce nicer results but run slower.
#[non_exhaustive]
#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
pub enum SmaaMode {
    /// Use SMAA 1x.
    Smaa1X,
}

pub mod resources;
use resources::*;
use wgpu::TextureView;

/// View-independent resources
pub struct SmaaShaders {
    pub pipelines: Pipelines,
    pub layouts: BindGroupLayouts,
    pub resources: Resources,
}
impl SmaaShaders {
    pub fn new(device: &wgpu::Device, queue: &wgpu::Queue, format: wgpu::TextureFormat) -> Self {
        let layouts = BindGroupLayouts::new(device);
        let pipelines = Pipelines::new(device, format, &layouts);
        let resources = Resources::new(device, queue);
        SmaaShaders {
            pipelines,
            layouts,
            resources,
        }
    }
}

/// View-specific resources
pub struct SmaaTarget {
    pub targets: Targets,
    pub bind_groups: BindGroups,

    pub color_target: TextureView,
}

impl SmaaTarget {
    /// Create a new `SmaaTarget`.
    pub fn new(
        smaa: &SmaaShaders,
        device: &wgpu::Device,
        width: u32,
        height: u32,
        format: wgpu::TextureFormat,
    ) -> Self {
        let color_texture = device.create_texture(
            &(wgpu::TextureDescriptor {
                size: wgpu::Extent3d {
                    width,
                    height,
                    depth_or_array_layers: 1,
                },
                mip_level_count: 1,
                sample_count: 1,
                dimension: wgpu::TextureDimension::D2,
                format,
                usage: wgpu::TextureUsages::RENDER_ATTACHMENT
                    | wgpu::TextureUsages::TEXTURE_BINDING,
                label: None,
            }),
        );
        let color_target = color_texture.create_view(&wgpu::TextureViewDescriptor {
            ..Default::default()
        });

        let targets = Targets::new(device, width, height);
        let bind_groups = BindGroups::new(
            device,
            &smaa.layouts,
            &smaa.resources,
            &targets,
            &color_target,
        );

        SmaaTarget {
            targets,
            bind_groups,
            color_target,
        }
    }
}

impl SmaaTarget {
    pub fn encode_commands(
        &self,
        smaa: &SmaaShaders,
        output_view: &wgpu::TextureView,
        encoder: &mut wgpu::CommandEncoder,
    ) {
        encode_commands(smaa, &self.targets, &self.bind_groups, output_view, encoder)
    }

    pub fn run(
        &self,
        smaa: &SmaaShaders,
        device: &wgpu::Device,
        queue: &wgpu::Queue,
        output_view: &wgpu::TextureView,
    ) {
        run(
            smaa,
            &self.targets,
            &self.bind_groups,
            device,
            queue,
            output_view,
        )
    }
}

pub fn encode_commands(
    smaa: &SmaaShaders,
    targets: &Targets,
    bind_groups: &BindGroups,
    output_view: &wgpu::TextureView,
    encoder: &mut wgpu::CommandEncoder,
) {
    {
        let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
            color_attachments: &[wgpu::RenderPassColorAttachment {
                view: &targets.edges_target,
                resolve_target: None,
                ops: wgpu::Operations {
                    load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
                    store: true,
                },
            }],
            depth_stencil_attachment: None,
            label: Some("smaa.render_pass.edge_detect"),
        });
        rpass.set_pipeline(&smaa.pipelines.edge_detect);
        rpass.set_bind_group(0, &bind_groups.edge_detect_bind_group, &[]);
        rpass.draw(0..3, 0..1);
    }
    {
        let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
            color_attachments: &[wgpu::RenderPassColorAttachment {
                view: &targets.blend_target,
                resolve_target: None,
                ops: wgpu::Operations {
                    load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
                    store: true,
                },
            }],
            depth_stencil_attachment: None,
            label: Some("smaa.render_pass.blend_weight"),
        });
        rpass.set_pipeline(&smaa.pipelines.blend_weight);
        rpass.set_bind_group(0, &bind_groups.blend_weight_bind_group, &[]);
        rpass.draw(0..3, 0..1);
    }
    {
        let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
            color_attachments: &[wgpu::RenderPassColorAttachment {
                view: output_view,
                resolve_target: None,
                ops: wgpu::Operations {
                    load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
                    store: true,
                },
            }],
            depth_stencil_attachment: None,
            label: Some("smaa.render_pass.neighborhood_blending"),
        });
        rpass.set_pipeline(&smaa.pipelines.neighborhood_blending);
        rpass.set_bind_group(0, &bind_groups.neighborhood_blending_bind_group, &[]);
        rpass.draw(0..3, 0..1);
    }
}

pub fn run(
    smaa: &SmaaShaders,
    targets: &Targets,
    bind_groups: &BindGroups,
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    output_view: &wgpu::TextureView,
) {
    let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
        label: Some("smaa.command_encoder"),
    });
    encode_commands(smaa, targets, bind_groups, output_view, &mut encoder);
    queue.submit(Some(encoder.finish()));
}
