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
    EdgeDetectionVS,
    LumaEdgeDetectionPS,

    BlendingWeightVS,
    BlendingWeightPS,

    NeighborhoodBlendingVS,
    NeighborhoodBlendingPS,
}

pub fn get_shader(
    stage: ShaderStage,
    _quality: ShaderQuality,
    name: &'static str,
    device: &wgpu::Device,
) -> wgpu::ShaderModule {
    let source = match stage {
        ShaderStage::EdgeDetectionVS => include_str!("../shaders/EdgeDetectionVS.wgsl"),
        ShaderStage::LumaEdgeDetectionPS => include_str!("../shaders/LumaEdgeDetectionPS.wgsl"),
        ShaderStage::BlendingWeightVS => include_str!("../shaders/BlendingWeightVS.wgsl"),
        ShaderStage::BlendingWeightPS => include_str!("../shaders/BlendingWeightPS.wgsl"),
        ShaderStage::NeighborhoodBlendingVS => {
            include_str!("../shaders/NeighborhoodBlendingVS.wgsl")
        }
        ShaderStage::NeighborhoodBlendingPS => {
            include_str!("../shaders/NeighborhoodBlendingPS.wgsl")
        }
    };

    device.create_shader_module(&wgpu::ShaderModuleDescriptor {
        label: Some(name),
        source: wgpu::ShaderSource::Wgsl(source.into()),
    })
}
