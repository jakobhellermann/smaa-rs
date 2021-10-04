#[derive(Debug, Clone, Copy)]
#[allow(dead_code)]
pub enum ShaderQuality {
    Low,
    Medium,
    High,
    Ultra,
}

#[derive(Debug)]
pub enum ShaderStage {
    EdgeDetectionVS,
    LumaEdgeDetectionPS,

    BlendingWeightVS,
    BlendingWeightPS,

    NeighborhoodBlendingVS,
    NeighborhoodBlendingPS,

    #[allow(dead_code)]
    NeighborhoodBlendingAcesTonemapPS,
}
#[path = "../shaders/spirv.rs"]
mod spirv;

pub fn get_shader(
    stage: ShaderStage,
    quality: ShaderQuality,
    name: &'static str,
    device: &wgpu::Device,
) -> wgpu::ShaderModule {
    device.create_shader_module(&spirv::get_spirv(stage, quality, name))
}
