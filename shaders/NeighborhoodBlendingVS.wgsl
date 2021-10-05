[[block]]
struct UniformBlock {
    rt: vec4<f32>;
};

struct VertexOutput {
    [[builtin(position)]] position: vec4<f32>;
    [[location(0)]] offset: vec4<f32>;
    [[location(1)]] texcoord: vec2<f32>;
};

[[group(0), binding(0)]]
var linearSampler: sampler;
[[group(0), binding(1)]]
var<uniform> uniforms: UniformBlock;

[[stage(vertex)]]
fn main([[builtin(vertex_index)]] gl_VertexIndex: u32) -> VertexOutput {
    var gl_Position: vec4<f32>;
    if ((gl_VertexIndex == u32(0))) {
        gl_Position = vec4<f32>(-1.0, -1.0, 1.0, 1.0);
    }
    if ((gl_VertexIndex == u32(1))) {
        gl_Position = vec4<f32>(-1.0, 3.0, 1.0, 1.0);
    }
    if ((gl_VertexIndex == u32(2))) {
        gl_Position = vec4<f32>(3.0, -1.0, 1.0, 1.0);
    }
    let texcoord = ((gl_Position.xy * vec2<f32>(0.5, -(0.5))) + vec2<f32>(0.5));
    let offset = (uniforms.rt.xyxy * vec4<f32>(1.0, 0.0, 0.0, 1.0)) + texcoord.xyxy;

    return VertexOutput(gl_Position, offset, texcoord);
}
