use crate::{ShaderQuality, ShaderStage};

#[rustfmt::skip]
pub fn get_spirv(stage: ShaderStage, quality: ShaderQuality, name: &'static str) -> wgpu::ShaderModuleDescriptor<'static> {
    let source: &[u8] = match (stage, quality) {
        (ShaderStage::EdgeDetectionVS, ShaderQuality::Low) => include_bytes!("../shaders/EdgeDetectionVS-Low.spv"),
        (ShaderStage::EdgeDetectionVS, ShaderQuality::Medium) => include_bytes!("../shaders/EdgeDetectionVS-Medium.spv"),
        (ShaderStage::EdgeDetectionVS, ShaderQuality::High) => include_bytes!("../shaders/EdgeDetectionVS-High.spv"),
        (ShaderStage::EdgeDetectionVS, ShaderQuality::Ultra) => include_bytes!("../shaders/EdgeDetectionVS-Ultra.spv"),
        (ShaderStage::LumaEdgeDetectionPS, ShaderQuality::Low) => include_bytes!("../shaders/LumaEdgeDetectionPS-Low.spv"),
        (ShaderStage::LumaEdgeDetectionPS, ShaderQuality::Medium) => include_bytes!("../shaders/LumaEdgeDetectionPS-Medium.spv"),
        (ShaderStage::LumaEdgeDetectionPS, ShaderQuality::High) => include_bytes!("../shaders/LumaEdgeDetectionPS-High.spv"),
        (ShaderStage::LumaEdgeDetectionPS, ShaderQuality::Ultra) => include_bytes!("../shaders/LumaEdgeDetectionPS-Ultra.spv"),
        (ShaderStage::BlendingWeightVS, ShaderQuality::Low) => include_bytes!("../shaders/BlendingWeightVS-Low.spv"),
        (ShaderStage::BlendingWeightVS, ShaderQuality::Medium) => include_bytes!("../shaders/BlendingWeightVS-Medium.spv"),
        (ShaderStage::BlendingWeightVS, ShaderQuality::High) => include_bytes!("../shaders/BlendingWeightVS-High.spv"),
        (ShaderStage::BlendingWeightVS, ShaderQuality::Ultra) => include_bytes!("../shaders/BlendingWeightVS-Ultra.spv"),
        (ShaderStage::BlendingWeightPS, ShaderQuality::Low) => include_bytes!("../shaders/BlendingWeightPS-Low.spv"),
        (ShaderStage::BlendingWeightPS, ShaderQuality::Medium) => include_bytes!("../shaders/BlendingWeightPS-Medium.spv"),
        (ShaderStage::BlendingWeightPS, ShaderQuality::High) => include_bytes!("../shaders/BlendingWeightPS-High.spv"),
        (ShaderStage::BlendingWeightPS, ShaderQuality::Ultra) => include_bytes!("../shaders/BlendingWeightPS-Ultra.spv"),
        (ShaderStage::NeighborhoodBlendingVS, ShaderQuality::Low) => include_bytes!("../shaders/NeighborhoodBlendingVS-Low.spv"),
        (ShaderStage::NeighborhoodBlendingVS, ShaderQuality::Medium) => include_bytes!("../shaders/NeighborhoodBlendingVS-Medium.spv"),
        (ShaderStage::NeighborhoodBlendingVS, ShaderQuality::High) => include_bytes!("../shaders/NeighborhoodBlendingVS-High.spv"),
        (ShaderStage::NeighborhoodBlendingVS, ShaderQuality::Ultra) => include_bytes!("../shaders/NeighborhoodBlendingVS-Ultra.spv"),
        (ShaderStage::NeighborhoodBlendingPS, ShaderQuality::Low) => include_bytes!("../shaders/NeighborhoodBlendingPS-Low.spv"),
        (ShaderStage::NeighborhoodBlendingPS, ShaderQuality::Medium) => include_bytes!("../shaders/NeighborhoodBlendingPS-Medium.spv"),
        (ShaderStage::NeighborhoodBlendingPS, ShaderQuality::High) => include_bytes!("../shaders/NeighborhoodBlendingPS-High.spv"),
        (ShaderStage::NeighborhoodBlendingPS, ShaderQuality::Ultra) => include_bytes!("../shaders/NeighborhoodBlendingPS-Ultra.spv"),
        (ShaderStage::NeighborhoodBlendingAcesTonemapPS, ShaderQuality::Low) => include_bytes!("../shaders/NeighborhoodBlendingAcesTonemapPS-Low.spv"),
        (ShaderStage::NeighborhoodBlendingAcesTonemapPS, ShaderQuality::Medium) => include_bytes!("../shaders/NeighborhoodBlendingAcesTonemapPS-Medium.spv"),
        (ShaderStage::NeighborhoodBlendingAcesTonemapPS, ShaderQuality::High) => include_bytes!("../shaders/NeighborhoodBlendingAcesTonemapPS-High.spv"),
        (ShaderStage::NeighborhoodBlendingAcesTonemapPS, ShaderQuality::Ultra) => include_bytes!("../shaders/NeighborhoodBlendingAcesTonemapPS-Ultra.spv"),
    };

    wgpu::ShaderModuleDescriptor {
        label: Some(name),
        source: wgpu::util::make_spirv(source),
        flags: wgpu::ShaderFlags::empty(),
    }
}
