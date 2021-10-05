use smaa::*;
use std::borrow::Cow;
use winit::event_loop::EventLoop;
use winit::{
    event::{Event, WindowEvent},
    event_loop::ControlFlow,
};

fn main() {
    // Initialize wgpu
    let event_loop: EventLoop<()> = EventLoop::new();
    let window = winit::window::Window::new(&event_loop).unwrap();
    let instance = wgpu::Instance::new(wgpu::Backends::PRIMARY);
    let surface = unsafe { instance.create_surface(&window) };
    let adapter =
        futures::executor::block_on(instance.request_adapter(&Default::default())).unwrap();
    let (device, queue) = futures::executor::block_on(adapter.request_device(
        &wgpu::DeviceDescriptor {
            features: wgpu::Features::SPIRV_SHADER_PASSTHROUGH,
            ..Default::default()
        },
        None,
    ))
    .unwrap();
    let surface_format = surface
        .get_preferred_format(&adapter)
        .unwrap_or(wgpu::TextureFormat::Bgra8UnormSrgb);
    surface.configure(
        &device,
        &wgpu::SurfaceConfiguration {
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            format: surface_format,
            width: window.inner_size().width,
            height: window.inner_size().height,
            present_mode: wgpu::PresentMode::Mailbox,
        },
    );

    // Create SMAA target
    let mut smaa_target = SmaaTarget::new(
        &device,
        &queue,
        window.inner_size().width,
        window.inner_size().height,
        surface_format,
        SmaaMode::Smaa1X,
    );

    // Prepare scene
    let shader = device.create_shader_module(&wgpu::ShaderModuleDescriptor {
        label: None,
        source: wgpu::ShaderSource::Wgsl(Cow::Borrowed(include_str!("shader.wgsl"))),
    });
    let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: None,
        bind_group_layouts: &[],
        push_constant_ranges: &[],
    });
    let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: None,
        layout: Some(&pipeline_layout),
        vertex: wgpu::VertexState {
            module: &shader,
            entry_point: "vs_main",
            buffers: &[],
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader,
            entry_point: "fs_main",
            targets: &[surface_format.into()],
        }),
        primitive: wgpu::PrimitiveState::default(),
        depth_stencil: None,
        multisample: wgpu::MultisampleState::default(),
    });

    // Main loop
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;
        match event {
            Event::WindowEvent {
                event: WindowEvent::Resized(size),
                ..
            } => {
                // Recreate the swap chain with the new size
                surface.configure(
                    &device,
                    &wgpu::SurfaceConfiguration {
                        usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
                        format: surface_format,
                        width: size.width,
                        height: size.height,
                        present_mode: wgpu::PresentMode::Mailbox,
                    },
                );
                smaa_target.resize(&device, size.width, size.height);
            }
            Event::RedrawRequested(_) => {
                let output_frame = surface.get_current_texture().unwrap();
                let view = output_frame
                    .texture
                    .create_view(&wgpu::TextureViewDescriptor::default());
                let frame = smaa_target.start_frame(&device, &queue, &view);

                let mut encoder =
                    device.create_command_encoder(&wgpu::CommandEncoderDescriptor { label: None });
                {
                    let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                        label: None,
                        color_attachments: &[wgpu::RenderPassColorAttachment {
                            view: &*frame,
                            resolve_target: None,
                            ops: wgpu::Operations {
                                load: wgpu::LoadOp::Clear(wgpu::Color::GREEN),
                                store: true,
                            },
                        }],
                        depth_stencil_attachment: None,
                    });
                    rpass.set_pipeline(&render_pipeline);
                    rpass.draw(0..3, 0..1);
                }
                queue.submit(Some(encoder.finish()));

                drop(frame);
                output_frame.present();
            }
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => {}
        }
    });
}
