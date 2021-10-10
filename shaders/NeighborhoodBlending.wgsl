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
fn vs_main([[builtin(vertex_index)]] gl_VertexIndex: u32) -> VertexOutput {
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


[[group(0), binding(2)]]
var colorTex: texture_2d<f32>;

[[group(0), binding(3)]]
var blendTex: texture_2d<f32>;

fn SMAAMovc(cond: vec2<bool>, variable: ptr<function, vec2<f32>>, value: vec2<f32>) {
    if (cond.x) {
        (*variable).x = value.x;
    }
    if (cond.y) {
        (*variable).y = value.y;
    }
}

fn SMAAMovc4(cond: vec4<bool>, variable: ptr<function, vec4<f32>>, value: vec4<f32>) {
    var result = (*variable).xy;
    SMAAMovc(cond.xy, &result, value.xy);
    *variable = vec4<f32>(result.x, result.y, (*variable).z, (*variable).w);

    var result2 = (*variable).zw;
    SMAAMovc(cond.zw, (&result2), value.zw);
    (*variable) = vec4<f32>((*variable).x, (*variable).y, result2.x, result2.y);
}

[[stage(fragment)]]
fn fs_main(in: VertexOutput) -> [[location(0)]] vec4<f32> {
    let offset = in.offset;
    let texcoord = in.texcoord;

    let ax = textureSample(blendTex, linearSampler, offset.xy).w;
    let ay = textureSample(blendTex, linearSampler, offset.zw).y;
    let azw = textureSample(blendTex, linearSampler, texcoord).xz;
    let a = vec4<f32>(ax, ay, azw.y, azw.x);

    if (dot(a, vec4<f32>(1.0)) < 0.00001) {
        return textureSampleLevel(colorTex, linearSampler, texcoord, 0.0);
    } else {
        let h = (max(a.x, a.z) > max(a.y, a.w));
        var blendingOffset = vec4<f32>(0.0, a.y, 0.0, a.w);
        var blendingWeight = a.yw;
        SMAAMovc4(vec4<bool>(h, h, h, h), (&blendingOffset), vec4<f32>(a.x, 0.0, a.z, 0.0));
        SMAAMovc(vec2<bool>(h, h), (&blendingWeight), a.xz);
        blendingWeight = (blendingWeight / vec2<f32>(dot(blendingWeight, vec2<f32>(1.0))));
        let blendingCoord = ((blendingOffset * vec4<f32>(uniforms.rt.xy, -(uniforms.rt.xy))) + texcoord.xyxy);
        var color = textureSampleLevel(colorTex, linearSampler, blendingCoord.xy, 0.0) * blendingWeight.x;
        color = (color + (textureSampleLevel(colorTex, linearSampler, blendingCoord.zw, 0.0) * blendingWeight.y));
        return color;
    }
}
