[[block]]
struct UniformBlock {
    rt: vec4<f32>;
};

struct FragmentOutput {
    [[location(0)]] OutColor: vec4<f32>;
};

[[group(0), binding(0)]]
var linearSampler: sampler;
[[group(0), binding(1)]]
var<uniform> uniforms: UniformBlock;
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

fn SMAAMovc1(cond: vec4<bool>, variable: ptr<function, vec4<f32>>, value: vec4<f32>) {
    var result = (*variable).xy;
    SMAAMovc(cond.xy, &result, value.xy);
    *variable = vec4<f32>(result.x, result.y, (*variable).z, (*variable).w);

    var result2 = (*variable).zw;
    SMAAMovc(cond.zw, (&result2), value.zw);
    (*variable) = vec4<f32>((*variable).x, (*variable).y, result2.x, result2.y);
}

fn SMAANeighborhoodBlendingPS(texcoord: vec2<f32>, offset: vec4<f32>, colorTex: texture_2d<f32>, blendTex: texture_2d<f32>) -> vec4<f32> {
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
        SMAAMovc1(vec4<bool>(h, h, h, h), (&blendingOffset), vec4<f32>(a.x, 0.0, a.z, 0.0));
        SMAAMovc(vec2<bool>(h, h), (&blendingWeight), a.xz);
        blendingWeight = (blendingWeight / vec2<f32>(dot(blendingWeight, vec2<f32>(1.0))));
        let blendingCoord = ((blendingOffset * vec4<f32>(uniforms.rt.xy, -(uniforms.rt.xy))) + texcoord.xyxy);
        var color = textureSampleLevel(colorTex, linearSampler, blendingCoord.xy, 0.0) * blendingWeight.x;
        color = (color + (textureSampleLevel(colorTex, linearSampler, blendingCoord.zw, 0.0) * blendingWeight.y));
        return color;
    }
}

[[stage(fragment)]]
fn main([[location(0)]] offset: vec4<f32>, [[location(1)]] texcoord: vec2<f32>) -> FragmentOutput {
    let color = SMAANeighborhoodBlendingPS(texcoord, offset, colorTex, blendTex);
    return FragmentOutput(color);
}
