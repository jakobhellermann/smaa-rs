#[derive(Copy, Clone)]
#[allow(dead_code)]
pub enum ShaderQuality {
    Low,
    Medium,
    High,
    Ultra,
}

#[derive(Copy, Clone)]
pub enum ShaderStage {
    EdgeDetection,
    BlendingWeight,
    NeighborhoodBlending,
}

pub fn get_shader(
    stage: ShaderStage,
    _quality: ShaderQuality,
    name: &'static str,
    device: &wgpu::Device,
) -> wgpu::ShaderModule {
    let source = match stage {
        ShaderStage::EdgeDetection => include_str!("../shaders/EdgeDetection.wgsl"),
        ShaderStage::BlendingWeight => include_str!("../shaders/BlendingWeight.wgsl"),
        ShaderStage::NeighborhoodBlending => {
            include_str!("../shaders/NeighborhoodBlending.wgsl")
        }
    };

    device.create_shader_module(&wgpu::ShaderModuleDescriptor {
        label: Some(name),
        source: wgpu::ShaderSource::Wgsl(source.into()),
    })
}
