#[derive(Debug, Clone, Copy)]
/// Controls the shader quality
pub enum ShaderQuality {
    /// 60% of the quality
    ///
    /// Threshold: 0.15<br>Max search steps: 4<br>No Diag Detection<br>No Corner detection
    Low,
    /// 80% of the quality
    ///
    /// Threshold: 0.1<br>Max search steps: 8<br>No Diag Detection<br>No Corner detection
    Medium,
    /// 95% of the quality
    ///
    /// Threshold: 0.1<br>Max search steps: 16<br>Diag Detection search steps: 8<br>Corner detection: 25
    High,
    /// 99% of the quality
    ///
    /// Threshold: 0.05<br>Max search steps: 32<br>Diag Detection search steps: 16<br>Corner detection: 25
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
