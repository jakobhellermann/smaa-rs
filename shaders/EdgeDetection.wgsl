[[block]]
struct UniformBlock {
    rt: vec4<f32>;
};

struct VertexOutput {
    [[builtin(position)]] member: vec4<f32>;
    [[location(0)]] offset0: vec4<f32>;
    [[location(1)]] offset1: vec4<f32>;
    [[location(2)]] offset2: vec4<f32>;
    [[location(3)]] texcoord: vec2<f32>;
};

[[group(0), binding(0)]]
var linearSampler: sampler;
[[group(0), binding(1)]]
var<uniform> uniforms: UniformBlock;

[[stage(vertex)]]
fn vs_main([[builtin(vertex_index)]] gl_VertexIndex: u32) -> VertexOutput {
    var gl_Position: vec4<f32>;
    if (gl_VertexIndex == u32(0)) {
        gl_Position = vec4<f32>(-(1.0), -(1.0), 1.0, 1.0);
    }
    if (gl_VertexIndex == u32(1)) {
        gl_Position = vec4<f32>(-(1.0), 3.0, 1.0, 1.0);
    }
    if (gl_VertexIndex == u32(2)) {
        gl_Position = vec4<f32>(3.0, -(1.0), 1.0, 1.0);
    }
    let texcoord = (gl_Position.xy * vec2<f32>(0.5, -0.5)) + vec2<f32>(0.5);

    let offset0 = (uniforms.rt.xyxy * vec4<f32>(-1.0, 0.0, 0.0, -1.0)) + texcoord.xyxy;
    let offset1 = (uniforms.rt.xyxy * vec4<f32>(1.0, 0.0, 0.0, 1.0)) + texcoord.xyxy;
    let offset2 = (uniforms.rt.xyxy * vec4<f32>(-2.0, 0.0, 0.0, -2.0)) + texcoord.xyxy;

    return VertexOutput(gl_Position, offset0, offset1, offset2, texcoord);
}


[[group(0), binding(2)]]
var colorTex: texture_2d<f32>;

fn SMAALumaEdgeDetectionPS(texcoord: vec2<f32>, offset: array<vec4<f32>,3>, colorTex: texture_2d<f32>) -> vec2<f32> {
    var threshold: vec2<f32> = vec2<f32>(0.05, 0.05);
    let weights = vec3<f32>(0.2126, 0.7152, 0.0722);

    let L = dot(textureSample(colorTex, linearSampler, texcoord).xyz, weights);
    let Lleft = dot(textureSample(colorTex, linearSampler, offset[0].xy).xyz, weights);
    let Ltop = dot(textureSample(colorTex, linearSampler, offset[0].zw).xyz, weights);

    let v0 = abs(L - vec2<f32>(Lleft, Ltop));
    var delta = vec4<f32>(v0.x, v0.y, 0.0, 0.0);
    var edges = step(threshold, delta.xy);

    let Lright = dot(textureSample(colorTex, linearSampler, offset[1].xy).xyz, weights);
    let Lbottom = dot(textureSample(colorTex, linearSampler, offset[1].zw).xyz, weights);
    let Lleftleft = dot(textureSample(colorTex, linearSampler, offset[2].xy).xyz, weights);
    let Ltoptop = dot(textureSample(colorTex, linearSampler, offset[2].zw).xyz, weights);

    if (dot(edges, vec2<f32>(1.0)) == 0.0) {
        discard;
    }

    let v1 = abs((vec2<f32>(L) - vec2<f32>(Lright, Lbottom)));
    delta = vec4<f32>(delta.x, delta.y, v1.x, v1.y);
    var maxDelta = max(delta.xy, delta.zw);

    let v2 = abs((vec2<f32>(Lleft, Ltop) - vec2<f32>(Lleftleft, Ltoptop)));
    delta = vec4<f32>(delta.x, delta.y, v2.x, v2.y);
    maxDelta = max(maxDelta, delta.zw);

    let finalDelta = max(maxDelta.x, maxDelta.y);
    edges = edges * step(vec2<f32>(finalDelta), (delta.xy * 2.0));

    return edges;
}

[[stage(fragment)]]
fn fs_main(in: VertexOutput) -> [[location(0)]] vec2<f32> {
    return SMAALumaEdgeDetectionPS(in.texcoord, array<vec4<f32>, 3>(in.offset0, in.offset1, in.offset2), colorTex);
}
