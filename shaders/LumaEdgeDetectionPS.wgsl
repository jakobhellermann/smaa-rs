[[block]]
struct UniformBlock {
    rt: vec4<f32>;
};

struct FragmentOutput {
    [[location(0)]] OutColor: vec2<f32>;
};

[[group(0), binding(0)]]
var linearSampler: sampler;

[[group(0), binding(1)]]
var<uniform> uniforms: UniformBlock;

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
fn main([[location(0)]] offset0_: vec4<f32>, [[location(1)]] offset1_: vec4<f32>, [[location(2)]] offset2_: vec4<f32>, [[location(3)]] texcoord: vec2<f32>) -> FragmentOutput {
    let color = SMAALumaEdgeDetectionPS(texcoord, array<vec4<f32>,3>(offset0_, offset1_, offset2_), colorTex);
    return FragmentOutput(color);
}
