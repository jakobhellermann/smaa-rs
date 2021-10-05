[[block]]
struct UniformBlock {
    rt: vec4<f32>;
};

struct FragmentOutput {
    [[location(0)]] OutColor: vec4<f32>;
};

[[group(0), binding(1)]]
var<uniform> uniforms: UniformBlock;
[[group(0), binding(0)]]
var linearSampler: sampler;
[[group(0), binding(2)]]
var edgesTex: texture_2d<f32>;
[[group(0), binding(3)]]
var areaTex: texture_2d<f32>;
[[group(0), binding(4)]]
var searchTex: texture_2d<f32>;
var<private> offset0_1: vec4<f32>;
var<private> offset1_1: vec4<f32>;
var<private> offset2_1: vec4<f32>;
var<private> OutColor: vec4<f32>;
var<private> texcoord1: vec2<f32>;
var<private> pixcoord1: vec2<f32>;

fn SMAADecodeDiagBilinearAccess1(e4: ptr<function, vec2<f32>>) -> vec2<f32> {
    let e15: vec2<f32> = (*e4);
    let e18: vec2<f32> = (*e4);
    let e24: vec2<f32> = (*e4);
    (*e4).x = (e15.x * abs(((5.0 * e24.x) - 3.75)));
    let e32: vec2<f32> = (*e4);
    return round(e32);
}


fn SMAASearchDiag1_(edgesTex: texture_2d<f32>, texcoord: vec2<f32>, dir: vec2<f32>, e: ptr<function, vec2<f32>>) -> vec2<f32> {
    var coord = vec4<f32>(texcoord, -1.0, 1.0);
    coord.x = coord.x + 0.25 * uniforms.rt.x;
    let t = vec3<f32>(uniforms.rt.xy, 1.0);

    loop {
        if (!(coord.z < 15.0 && coord.w > 0.9)) {
            break;
        }

        let v2 = (t * vec3<f32>(dir, 1.0)) + coord.xyz;
        coord = vec4<f32>(v2.x, v2.y, v2.z, coord.w);
        let val = textureSampleLevel(edgesTex, linearSampler, coord.xy, 0.0).xy;
        *e = val;
        coord.w = dot(val, vec2<f32>(0.5));
    }
    return coord.zw;
}


fn SMAASearchDiag2_(edgesTex1: texture_2d<f32>, texcoord: vec2<f32>, dir2: vec2<f32>, e5: ptr<function, vec2<f32>>) -> vec2<f32> {
    let coord = vec4<f32>(texcoord, -1.0, 1.0);
    let t = vec3<f32>(uniforms.rt.xy, 1.0);

    var texcoord: vec2<f32>;
    var dir3: vec2<f32>;
    var coord1: vec4<f32>;
    var t1: vec3<f32>;
    var v4: bool;
    var v5: bool;
    var v6: vec3<f32>;
    var param: vec2<f32>;
    var v7: vec2<f32>;

    
    dir3 = dir2;
    let e19: vec2<f32> = texcoord;
    coord1 = vec4<f32>(e19, -(1.0), 1.0);
    let e26: vec4<f32> = coord1;
    let e29: UniformBlock = uniforms;
    coord1.x = (e26.x + (0.25 * e29.rt.x));
    let e34: UniformBlock = uniforms;
    t1 = vec3<f32>(e34.rt.xy, 1.0);
    loop {
        {
            let e40: vec4<f32> = coord1;
            v4 = (e40.z < 15.0);
            let e46: bool = v4;
            if (e46) {
                {
                    let e47: vec4<f32> = coord1;
                    v5 = (e47.w > 0.8999999761581421);
                }
            } else {
                {
                    let e51: bool = v4;
                    v5 = e51;
                }
            }
            let e52: bool = v5;
            if (e52) {
                {
                    let e53: vec3<f32> = t1;
                    let e54: vec2<f32> = dir3;
                    let e58: vec4<f32> = coord1;
                    v6 = ((e53 * vec3<f32>(e54, 1.0)) + e58.xyz);
                    let e62: vec3<f32> = v6;
                    let e64: vec3<f32> = v6;
                    let e66: vec3<f32> = v6;
                    let e68: vec4<f32> = coord1;
                    coord1 = vec4<f32>(e62.x, e64.y, e66.z, e68.w);
                    let e71: vec4<f32> = coord1;
                    let e74: vec4<f32> = coord1;
                    let e77: vec4<f32> = textureSampleLevel(edgesTex1, linearSampler, e74.xy, 0.0);
                    (*e5) = e77.xy;
                    let e79: vec2<f32> = (*e5);
                    param = e79;
                    let e82: vec2<f32> = SMAADecodeDiagBilinearAccess1((&param));
                    v7 = e82;
                    let e84: vec2<f32> = v7;
                    (*e5) = e84;
                    let e89: vec2<f32> = (*e5);
                    coord1.w = dot(e89, vec2<f32>(0.5));
                    continue;
                }
            } else {
                {
                    break;
                }
            }
        }
    }
    let e93: vec4<f32> = coord1;
    return e93.zw;
}


fn SMAADecodeDiagBilinearAccess(e1: ptr<function, vec4<f32>>) -> vec4<f32> {
    var v3: vec2<f32>;

    let e14: vec4<f32> = (*e1);
    let e16: vec4<f32> = (*e1);
    let e23: vec4<f32> = (*e1);
    v3 = (e14.xz * abs(((e23.xz * 5.0) - vec2<f32>(3.75))));
    let e33: vec2<f32> = v3;
    let e35: vec4<f32> = (*e1);
    let e37: vec2<f32> = v3;
    let e39: vec4<f32> = (*e1);
    (*e1) = vec4<f32>(e33.x, e35.y, e37.y, e39.w);
    let e43: vec4<f32> = (*e1);
    return round(e43);
}

fn SMAAMovc(cond: vec2<bool>, variable: ptr<function, vec2<f32>>, value: vec2<f32>) {
    var cond1: vec2<bool>;
    var value1: vec2<f32>;

    cond1 = cond;
    value1 = value;
    let e18: vec2<bool> = cond1;
    if (e18.x) {
        {
            let e21: vec2<f32> = value1;
            (*variable).x = e21.x;
        }
    }
    let e23: vec2<bool> = cond1;
    if (e23.y) {
        {
            let e26: vec2<f32> = value1;
            (*variable).y = e26.y;
            return;
        }
    } else {
        return;
    }
}

fn SMAAAreaDiag(areaTex_1_: texture_2d<f32>, dist: vec2<f32>, e2: vec2<f32>, offset: f32) -> vec2<f32> {
    var dist1: vec2<f32>;
    var e3: vec2<f32>;
    var offset1: f32;
    var texcoord: vec2<f32>;

    dist1 = dist;
    e3 = e2;
    offset1 = offset;
    let e22: vec2<f32> = e3;
    let e24: vec2<f32> = dist1;
    texcoord = ((vec2<f32>(20.0) * e22) + e24);
    let e30: vec2<f32> = texcoord;
    texcoord = ((vec2<f32>(0.0062500000931322575, 0.0017857142956927419) * e30) + vec2<f32>(0.0031250000465661287, 0.0008928571478463709));
    let e37: vec2<f32> = texcoord;
    texcoord.x = (e37.x + 0.5);
    let e42: vec2<f32> = texcoord;
    let e45: f32 = offset1;
    texcoord.y = (e42.y + (0.1428571492433548 * e45));
    let e50: vec2<f32> = texcoord;
    let e52: vec4<f32> = textureSampleLevel(areaTex_1_, linearSampler, e50, 0.0);
    return e52.xy;
}

fn SMAACalculateDiagWeights(edgesTex2: texture_2d<f32>, areaTex_1_1: texture_2d<f32>, texcoord: vec2<f32>, e6: vec2<f32>, subsampleIndices: vec4<f32>) -> vec2<f32> {
    var texcoord: vec2<f32>;
    var e7: vec2<f32>;
    var subsampleIndices1: vec4<f32>;
    var weights: vec2<f32> = vec2<f32>(0.0, 0.0);
    var d: vec4<f32>;
    var end: vec2<f32>;
    var param1: vec2<f32>;
    var param_1_: vec2<f32> = vec2<f32>(-1.0, 1.0);
    var param_2_: vec2<f32>;
    var v8: vec2<f32>;
    var param_3_: vec2<f32>;
    var param_4_: vec2<f32> = vec2<f32>(1.0, -1.0);
    var param_5_: vec2<f32>;
    var v9: vec2<f32>;
    var coords: vec4<f32>;
    var v10: vec2<f32>;
    var c: vec4<f32>;
    var v11: vec2<f32>;
    var param_6_: vec4<f32>;
    var v12: vec4<f32>;
    var cc: vec2<f32>;
    var param_7_before: vec2<bool>;
    var param_7_: vec2<bool>;
    var param_8_: vec2<f32>;
    var param_9_: vec2<f32> = vec2<f32>(0.0, 0.0);
    var param_10_: vec2<f32>;
    var param_11_: vec2<f32>;
    var param_12_: f32;
    var param_13_: vec2<f32>;
    var param_14_: vec2<f32> = vec2<f32>(-1.0, -1.0);
    var param_15_: vec2<f32>;
    var v13: vec2<f32>;
    var param_16_: vec2<f32>;
    var param_17_: vec2<f32> = vec2<f32>(1.0, 1.0);
    var param_18_: vec2<f32>;
    var v14: vec2<f32>;
    var coords_1_: vec4<f32>;
    var c_1_: vec4<f32>;
    var v15: vec2<f32>;
    var cc_1_: vec2<f32>;
    var param_19_before: vec2<bool>;
    var param_19_: vec2<bool>;
    var param_20_: vec2<f32>;
    var param_21_: vec2<f32> = vec2<f32>(0.0, 0.0);
    var param_22_: vec2<f32>;
    var param_23_: vec2<f32>;
    var param_24_: f32;

    
    e7 = e6;
    subsampleIndices1 = subsampleIndices;
    let e26: vec2<f32> = e7;
    if ((e26.x > 0.0)) {
        {
            let e30: vec2<f32> = texcoord;
            param1 = e30;
            let e41: vec2<f32> = param1;
            let e42: vec2<f32> = param_1_;
            let e43: vec2<f32> = SMAASearchDiag1_(edgesTex2, e41, e42, (&param_2_));
            v8 = e43;
            let e45: vec2<f32> = param_2_;
            end = e45;
            let e46: vec2<f32> = v8;
            let e48: vec4<f32> = d;
            let e50: vec2<f32> = v8;
            let e52: vec4<f32> = d;
            d = vec4<f32>(e46.x, e48.y, e50.y, e52.w);
            let e56: vec4<f32> = d;
            let e58: vec2<f32> = end;
            d.x = (e56.x + select(0.0, 1.0, (e58.y > 0.8999999761581421)));
        }
    } else {
        {
            let e69: vec4<f32> = d;
            let e74: vec4<f32> = d;
            d = vec4<f32>(vec2<f32>(0.0).x, e69.y, vec2<f32>(0.0).y, e74.w);
        }
    }
    let e77: vec2<f32> = texcoord;
    param_3_ = e77;
    let e88: vec2<f32> = param_3_;
    let e89: vec2<f32> = param_4_;
    let e90: vec2<f32> = SMAASearchDiag1_(edgesTex2, e88, e89, (&param_5_));
    v9 = e90;
    let e92: vec2<f32> = param_5_;
    end = e92;
    let e93: vec4<f32> = d;
    let e95: vec2<f32> = v9;
    let e97: vec4<f32> = d;
    let e99: vec2<f32> = v9;
    d = vec4<f32>(e93.x, e95.x, e97.z, e99.y);
    let e102: vec4<f32> = d;
    let e104: vec4<f32> = d;
    if (((e102.x + e104.y) > 2.0)) {
        {
            let e109: vec4<f32> = d;
            let e114: vec4<f32> = d;
            let e116: vec4<f32> = d;
            let e118: vec4<f32> = d;
            let e124: UniformBlock = uniforms;
            let e128: vec2<f32> = texcoord;
            coords = ((vec4<f32>((-(e109.x) + 0.25), e114.x, e116.y, (-(e118.y) - 0.25)) * e124.rt.xyxy) + e128.xyxy);
            let e132: vec4<f32> = coords;
            let e139: vec4<f32> = coords;
            let e146: vec4<f32> = textureSampleLevel(edgesTex2, linearSampler, e139.xy, 0.0, vec2<i32>(-1, 0));
            v10 = e146.xy;
            let e150: vec2<f32> = v10;
            let e152: vec2<f32> = v10;
            let e154: vec4<f32> = c;
            let e156: vec4<f32> = c;
            c = vec4<f32>(e150.x, e152.y, e154.z, e156.w);
            let e159: vec4<f32> = coords;
            let e165: vec4<f32> = coords;
            let e171: vec4<f32> = textureSampleLevel(edgesTex2, linearSampler, e165.zw, 0.0, vec2<i32>(1, 0));
            v11 = e171.xy;
            let e174: vec4<f32> = c;
            let e176: vec4<f32> = c;
            let e178: vec2<f32> = v11;
            let e180: vec2<f32> = v11;
            c = vec4<f32>(e174.x, e176.y, e178.x, e180.y);
            let e183: vec4<f32> = c;
            param_6_ = e183;
            let e186: vec4<f32> = SMAADecodeDiagBilinearAccess((&param_6_));
            v12 = e186;
            let e188: vec4<f32> = v12;
            let e190: vec4<f32> = v12;
            let e192: vec4<f32> = v12;
            let e194: vec4<f32> = v12;
            c = vec4<f32>(e188.y, e190.x, e192.w, e194.z);
            let e199: vec4<f32> = c;
            let e202: vec4<f32> = c;
            cc = ((vec2<f32>(2.0) * e199.xz) + e202.yw);
            let e208: vec4<f32> = d;
            let e212: vec4<f32> = d;
            let e219: vec4<f32> = d;
            let e223: vec4<f32> = d;
            param_7_before = (step(vec2<f32>(0.8999999761581421), e223.zw) == vec2<f32>(0.0));
            let e230: vec2<bool> = param_7_before;
            let e233: vec2<bool> = param_7_before;
            param_7_ = vec2<bool>(!(e230.x), !(e233.y));
            let e238: vec2<f32> = cc;
            param_8_ = e238;
            let e246: vec2<bool> = param_7_;
            let e247: vec2<f32> = param_9_;
            SMAAMovc(e246, (&param_8_), e247);
            let e248: vec2<f32> = param_8_;
            cc = e248;
            let e249: vec4<f32> = d;
            param_10_ = e249.xy;
            let e252: vec2<f32> = cc;
            param_11_ = e252;
            let e254: vec4<f32> = subsampleIndices1;
            param_12_ = e254.z;
            let e257: vec2<f32> = weights;
            let e261: vec2<f32> = param_10_;
            let e262: vec2<f32> = param_11_;
            let e263: f32 = param_12_;
            let e264: vec2<f32> = SMAAAreaDiag(areaTex_1_1, e261, e262, e263);
            weights = (e257 + e264);
        }
    }
    let e266: vec2<f32> = texcoord;
    param_13_ = e266;
    let e276: vec2<f32> = param_13_;
    let e277: vec2<f32> = param_14_;
    let e278: vec2<f32> = SMAASearchDiag2_(edgesTex2, e276, e277, (&param_15_));
    v13 = e278;
    let e280: vec2<f32> = param_15_;
    end = e280;
    let e281: vec2<f32> = v13;
    let e283: vec4<f32> = d;
    let e285: vec2<f32> = v13;
    let e287: vec4<f32> = d;
    d = vec4<f32>(e281.x, e283.y, e285.y, e287.w);
    let e295: vec2<f32> = texcoord;
    let e300: vec4<f32> = textureSampleLevel(edgesTex2, linearSampler, e295, 0.0, vec2<i32>(1, 0));
    if ((e300.x > 0.0)) {
        {
            let e304: vec2<f32> = texcoord;
            param_16_ = e304;
            let e313: vec2<f32> = param_16_;
            let e314: vec2<f32> = param_17_;
            let e315: vec2<f32> = SMAASearchDiag2_(edgesTex2, e313, e314, (&param_18_));
            v14 = e315;
            let e317: vec2<f32> = param_18_;
            end = e317;
            let e318: vec4<f32> = d;
            let e320: vec2<f32> = v14;
            let e322: vec4<f32> = d;
            let e324: vec2<f32> = v14;
            d = vec4<f32>(e318.x, e320.x, e322.z, e324.y);
            let e328: vec4<f32> = d;
            let e330: vec2<f32> = end;
            d.y = (e328.y + select(0.0, 1.0, (e330.y > 0.8999999761581421)));
        }
    } else {
        {
            let e338: vec4<f32> = d;
            let e343: vec4<f32> = d;
            d = vec4<f32>(e338.x, vec2<f32>(0.0).x, e343.z, vec2<f32>(0.0).y);
        }
    }
    let e349: vec4<f32> = d;
    let e351: vec4<f32> = d;
    if (((e349.x + e351.y) > 2.0)) {
        {
            let e356: vec4<f32> = d;
            let e359: vec4<f32> = d;
            let e362: vec4<f32> = d;
            let e364: vec4<f32> = d;
            let e367: UniformBlock = uniforms;
            let e371: vec2<f32> = texcoord;
            coords_1_ = ((vec4<f32>(-(e356.x), -(e359.x), e362.y, e364.y) * e367.rt.xyxy) + e371.xyxy);
            let e377: vec4<f32> = coords_1_;
            let e384: vec4<f32> = coords_1_;
            let e391: vec4<f32> = textureSampleLevel(edgesTex2, linearSampler, e384.xy, 0.0, vec2<i32>(-1, 0));
            c_1_.x = e391.y;
            let e394: vec4<f32> = coords_1_;
            let e401: vec4<f32> = coords_1_;
            let e408: vec4<f32> = textureSampleLevel(edgesTex2, linearSampler, e401.xy, 0.0, vec2<i32>(0, -1));
            c_1_.y = e408.x;
            let e410: vec4<f32> = coords_1_;
            let e416: vec4<f32> = coords_1_;
            let e422: vec4<f32> = textureSampleLevel(edgesTex2, linearSampler, e416.zw, 0.0, vec2<i32>(1, 0));
            v15 = e422.yx;
            let e425: vec4<f32> = c_1_;
            let e427: vec4<f32> = c_1_;
            let e429: vec2<f32> = v15;
            let e431: vec2<f32> = v15;
            c_1_ = vec4<f32>(e425.x, e427.y, e429.x, e431.y);
            let e436: vec4<f32> = c_1_;
            let e439: vec4<f32> = c_1_;
            cc_1_ = ((vec2<f32>(2.0) * e436.xz) + e439.yw);
            let e445: vec4<f32> = d;
            let e449: vec4<f32> = d;
            let e456: vec4<f32> = d;
            let e460: vec4<f32> = d;
            param_19_before = (step(vec2<f32>(0.8999999761581421), e460.zw) == vec2<f32>(0.0));
            let e467: vec2<bool> = param_19_before;
            let e470: vec2<bool> = param_19_before;
            param_19_ = vec2<bool>(!(e467.x), !(e470.y));
            let e475: vec2<f32> = cc_1_;
            param_20_ = e475;
            let e483: vec2<bool> = param_19_;
            let e484: vec2<f32> = param_21_;
            SMAAMovc(e483, (&param_20_), e484);
            let e485: vec2<f32> = param_20_;
            cc_1_ = e485;
            let e486: vec4<f32> = d;
            param_22_ = e486.xy;
            let e489: vec2<f32> = cc_1_;
            param_23_ = e489;
            let e491: vec4<f32> = subsampleIndices1;
            param_24_ = e491.w;
            let e494: vec2<f32> = weights;
            let e498: vec2<f32> = param_22_;
            let e499: vec2<f32> = param_23_;
            let e500: f32 = param_24_;
            let e501: vec2<f32> = SMAAAreaDiag(areaTex_1_1, e498, e499, e500);
            weights = (e494 + e501.yx);
        }
    }
    let e504: vec2<f32> = weights;
    return e504;
}

fn SMAASearchLength(searchTex_1_: texture_2d<f32>, e8: vec2<f32>, offset2: f32) -> f32 {
    var e9: vec2<f32>;
    var offset3: f32;
    var scale: vec2<f32> = vec2<f32>(33.0, -33.0);
    var bias: vec2<f32>;

    e9 = e8;
    offset3 = offset2;
    let e26: f32 = offset3;
    bias = (vec2<f32>(66.0, 33.0) * vec2<f32>(e26, 1.0));
    let e31: vec2<f32> = scale;
    scale = (e31 + vec2<f32>(-(1.0), 1.0));
    let e37: vec2<f32> = bias;
    bias = (e37 + vec2<f32>(0.5, -(0.5)));
    let e43: vec2<f32> = scale;
    scale = (e43 * vec2<f32>(0.015625, 0.0625));
    let e48: vec2<f32> = bias;
    bias = (e48 * vec2<f32>(0.015625, 0.0625));
    let e53: vec2<f32> = scale;
    let e54: vec2<f32> = e9;
    let e56: vec2<f32> = bias;
    let e59: vec2<f32> = scale;
    let e60: vec2<f32> = e9;
    let e62: vec2<f32> = bias;
    let e65: vec4<f32> = textureSampleLevel(searchTex_1_, linearSampler, ((e59 * e60) + e62), 0.0);
    return e65.x;
}

fn SMAASearchXLeft(edgesTex3: texture_2d<f32>, searchTex_1_1: texture_2d<f32>, texcoord: ptr<function, vec2<f32>>, end1: f32) -> f32 {
    var end2: f32;
    var e10: vec2<f32> = vec2<f32>(0.0, 1.0);
    var v16: bool;
    var v17: bool;
    var v18: bool;
    var param2: vec2<f32>;
    var param_1_1: f32 = 0.0;
    var offset4: f32;

    end2 = end1;
    loop {
        {
            let e22: vec2<f32> = (*texcoord);
            let e24: f32 = end2;
            v16 = (e22.x > e24);
            let e28: bool = v16;
            if (e28) {
                {
                    let e29: vec2<f32> = e10;
                    v17 = (e29.y > 0.8281000256538391);
                }
            } else {
                {
                    let e33: bool = v16;
                    v17 = e33;
                }
            }
            let e35: bool = v17;
            if (e35) {
                {
                    let e36: vec2<f32> = e10;
                    v18 = (e36.x == 0.0);
                }
            } else {
                {
                    let e40: bool = v17;
                    v18 = e40;
                }
            }
            let e41: bool = v18;
            if (e41) {
                {
                    let e44: vec2<f32> = (*texcoord);
                    let e46: vec4<f32> = textureSampleLevel(edgesTex3, linearSampler, e44, 0.0);
                    e10 = e46.xy;
                    let e53: UniformBlock = uniforms;
                    let e57: vec2<f32> = (*texcoord);
                    (*texcoord) = ((vec2<f32>(-(2.0), -(0.0)) * e53.rt.xy) + e57);
                    continue;
                }
            } else {
                {
                    break;
                }
            }
        }
    }
    let e59: vec2<f32> = e10;
    param2 = e59;
    let e67: vec2<f32> = param2;
    let e68: f32 = param_1_1;
    let e69: f32 = SMAASearchLength(searchTex_1_1, e67, e68);
    offset4 = ((-(2.007874011993408) * e69) + 3.25);
    let e74: UniformBlock = uniforms;
    let e77: f32 = offset4;
    let e79: vec2<f32> = (*texcoord);
    return ((e74.rt.x * e77) + e79.x);
}

fn SMAASearchXRight(edgesTex4: texture_2d<f32>, searchTex_1_2: texture_2d<f32>, texcoord: ptr<function, vec2<f32>>, end3: f32) -> f32 {
    var end4: f32;
    var e11: vec2<f32> = vec2<f32>(0.0, 1.0);
    var v19: bool;
    var v20: bool;
    var v21: bool;
    var param3: vec2<f32>;
    var param_1_2: f32 = 0.5;
    var offset5: f32;

    end4 = end3;
    loop {
        {
            let e22: vec2<f32> = (*texcoord);
            let e24: f32 = end4;
            v19 = (e22.x < e24);
            let e28: bool = v19;
            if (e28) {
                {
                    let e29: vec2<f32> = e11;
                    v20 = (e29.y > 0.8281000256538391);
                }
            } else {
                {
                    let e33: bool = v19;
                    v20 = e33;
                }
            }
            let e35: bool = v20;
            if (e35) {
                {
                    let e36: vec2<f32> = e11;
                    v21 = (e36.x == 0.0);
                }
            } else {
                {
                    let e40: bool = v20;
                    v21 = e40;
                }
            }
            let e41: bool = v21;
            if (e41) {
                {
                    let e44: vec2<f32> = (*texcoord);
                    let e46: vec4<f32> = textureSampleLevel(edgesTex4, linearSampler, e44, 0.0);
                    e11 = e46.xy;
                    let e51: UniformBlock = uniforms;
                    let e55: vec2<f32> = (*texcoord);
                    (*texcoord) = ((vec2<f32>(2.0, 0.0) * e51.rt.xy) + e55);
                    continue;
                }
            } else {
                {
                    break;
                }
            }
        }
    }
    let e57: vec2<f32> = e11;
    param3 = e57;
    let e65: vec2<f32> = param3;
    let e66: f32 = param_1_2;
    let e67: f32 = SMAASearchLength(searchTex_1_2, e65, e66);
    offset5 = ((-(2.007874011993408) * e67) + 3.25);
    let e72: UniformBlock = uniforms;
    let e76: f32 = offset5;
    let e78: vec2<f32> = (*texcoord);
    return ((-(e72.rt.x) * e76) + e78.x);
}

fn SMAAArea(areaTex_1_2: texture_2d<f32>, dist2: vec2<f32>, e1_: f32, e2_: f32, offset6: f32) -> vec2<f32> {
    var dist3: vec2<f32>;
    var e1_1: f32;
    var e2_1: f32;
    var offset7: f32;
    var texcoord: vec2<f32>;

    dist3 = dist2;
    e1_1 = e1_;
    e2_1 = e2_;
    offset7 = offset6;
    let e24: f32 = e1_1;
    let e25: f32 = e2_1;
    let e29: f32 = e1_1;
    let e30: f32 = e2_1;
    let e36: vec2<f32> = dist3;
    texcoord = ((vec2<f32>(16.0) * round((vec2<f32>(e29, e30) * 4.0))) + e36);
    let e42: vec2<f32> = texcoord;
    texcoord = ((vec2<f32>(0.0062500000931322575, 0.0017857142956927419) * e42) + vec2<f32>(0.0031250000465661287, 0.0008928571478463709));
    let e50: f32 = offset7;
    let e52: vec2<f32> = texcoord;
    texcoord.y = ((0.1428571492433548 * e50) + e52.y);
    let e57: vec2<f32> = texcoord;
    let e59: vec4<f32> = textureSampleLevel(areaTex_1_2, linearSampler, e57, 0.0);
    return e59.xy;
}

fn SMAADetectHorizontalCornerPattern(edgesTex5: texture_2d<f32>, weights1: ptr<function, vec2<f32>>, texcoord0: vec4<f32>, d1: vec2<f32>) {
    var texcoord1: vec4<f32>;
    var d2: vec2<f32>;
    var leftRight: vec2<f32>;
    var rounding: vec2<f32>;
    var factor: vec2<f32> = vec2<f32>(1.0, 1.0);

    texcoord1 = texcoord0;
    d2 = d1;
    let e20: vec2<f32> = d2;
    let e22: vec2<f32> = d2;
    let e23: vec2<f32> = d2;
    leftRight = step(e22, e23.yx);
    let e27: vec2<f32> = leftRight;
    rounding = (e27 * 0.75);
    let e31: vec2<f32> = rounding;
    let e32: vec2<f32> = leftRight;
    let e34: vec2<f32> = leftRight;
    rounding = (e31 / vec2<f32>((e32.x + e34.y)));
    let e43: vec2<f32> = factor;
    let e45: vec2<f32> = rounding;
    let e47: vec4<f32> = texcoord1;
    let e53: vec4<f32> = texcoord1;
    let e59: vec4<f32> = textureSampleLevel(edgesTex5, linearSampler, e53.xy, 0.0, vec2<i32>(0, 1));
    factor.x = (e43.x - (e45.x * e59.x));
    let e64: vec2<f32> = factor;
    let e66: vec2<f32> = rounding;
    let e68: vec4<f32> = texcoord1;
    let e73: vec4<f32> = texcoord1;
    let e78: vec4<f32> = textureSampleLevel(edgesTex5, linearSampler, e73.zw, 0.0, vec2<i32>(1, 1));
    factor.x = (e64.x - (e66.y * e78.x));
    let e83: vec2<f32> = factor;
    let e85: vec2<f32> = rounding;
    let e87: vec4<f32> = texcoord1;
    let e94: vec4<f32> = texcoord1;
    let e101: vec4<f32> = textureSampleLevel(edgesTex5, linearSampler, e94.xy, 0.0, vec2<i32>(0, -2));
    factor.y = (e83.y - (e85.x * e101.x));
    let e106: vec2<f32> = factor;
    let e108: vec2<f32> = rounding;
    let e110: vec4<f32> = texcoord1;
    let e117: vec4<f32> = texcoord1;
    let e124: vec4<f32> = textureSampleLevel(edgesTex5, linearSampler, e117.zw, 0.0, vec2<i32>(1, -2));
    factor.y = (e106.y - (e108.y * e124.x));
    let e128: vec2<f32> = (*weights1);
    let e134: vec2<f32> = factor;
    (*weights1) = (e128 * clamp(e134, vec2<f32>(0.0), vec2<f32>(1.0)));
    return;
}

fn SMAASearchYUp(edgesTex6: texture_2d<f32>, searchTex_1_3: texture_2d<f32>, texcoord2: ptr<function, vec2<f32>>, end5: f32) -> f32 {
    var end6: f32;
    var e12: vec2<f32> = vec2<f32>(1.0, 0.0);
    var v22: bool;
    var v23: bool;
    var v24: bool;
    var param4: vec2<f32>;
    var param_1_3: f32 = 0.0;
    var offset8: f32;

    end6 = end5;
    loop {
        {
            let e22: vec2<f32> = (*texcoord2);
            let e24: f32 = end6;
            v22 = (e22.y > e24);
            let e28: bool = v22;
            if (e28) {
                {
                    let e29: vec2<f32> = e12;
                    v23 = (e29.x > 0.8281000256538391);
                }
            } else {
                {
                    let e33: bool = v22;
                    v23 = e33;
                }
            }
            let e35: bool = v23;
            if (e35) {
                {
                    let e36: vec2<f32> = e12;
                    v24 = (e36.y == 0.0);
                }
            } else {
                {
                    let e40: bool = v23;
                    v24 = e40;
                }
            }
            let e41: bool = v24;
            if (e41) {
                {
                    let e44: vec2<f32> = (*texcoord2);
                    let e46: vec4<f32> = textureSampleLevel(edgesTex6, linearSampler, e44, 0.0);
                    e12 = e46.xy;
                    let e53: UniformBlock = uniforms;
                    let e57: vec2<f32> = (*texcoord2);
                    (*texcoord2) = ((vec2<f32>(-(0.0), -(2.0)) * e53.rt.xy) + e57);
                    continue;
                }
            } else {
                {
                    break;
                }
            }
        }
    }
    let e59: vec2<f32> = e12;
    param4 = e59.yx;
    let e68: vec2<f32> = param4;
    let e69: f32 = param_1_3;
    let e70: f32 = SMAASearchLength(searchTex_1_3, e68, e69);
    offset8 = ((-(2.007874011993408) * e70) + 3.25);
    let e75: UniformBlock = uniforms;
    let e78: f32 = offset8;
    let e80: vec2<f32> = (*texcoord2);
    return ((e75.rt.y * e78) + e80.y);
}

fn SMAASearchYDown(edgesTex7: texture_2d<f32>, searchTex_1_4: texture_2d<f32>, texcoord3: ptr<function, vec2<f32>>, end7: f32) -> f32 {
    var end8: f32;
    var e13: vec2<f32> = vec2<f32>(1.0, 0.0);
    var v25: bool;
    var v26: bool;
    var v27: bool;
    var param5: vec2<f32>;
    var param_1_4: f32 = 0.5;
    var offset9: f32;

    end8 = end7;
    loop {
        {
            let e22: vec2<f32> = (*texcoord3);
            let e24: f32 = end8;
            v25 = (e22.y < e24);
            let e28: bool = v25;
            if (e28) {
                {
                    let e29: vec2<f32> = e13;
                    v26 = (e29.x > 0.8281000256538391);
                }
            } else {
                {
                    let e33: bool = v25;
                    v26 = e33;
                }
            }
            let e35: bool = v26;
            if (e35) {
                {
                    let e36: vec2<f32> = e13;
                    v27 = (e36.y == 0.0);
                }
            } else {
                {
                    let e40: bool = v26;
                    v27 = e40;
                }
            }
            let e41: bool = v27;
            if (e41) {
                {
                    let e44: vec2<f32> = (*texcoord3);
                    let e46: vec4<f32> = textureSampleLevel(edgesTex7, linearSampler, e44, 0.0);
                    e13 = e46.xy;
                    let e51: UniformBlock = uniforms;
                    let e55: vec2<f32> = (*texcoord3);
                    (*texcoord3) = ((vec2<f32>(0.0, 2.0) * e51.rt.xy) + e55);
                    continue;
                }
            } else {
                {
                    break;
                }
            }
        }
    }
    let e57: vec2<f32> = e13;
    param5 = e57.yx;
    let e66: vec2<f32> = param5;
    let e67: f32 = param_1_4;
    let e68: f32 = SMAASearchLength(searchTex_1_4, e66, e67);
    offset9 = ((-(2.007874011993408) * e68) + 3.25);
    let e73: UniformBlock = uniforms;
    let e77: f32 = offset9;
    let e79: vec2<f32> = (*texcoord3);
    return ((-(e73.rt.y) * e77) + e79.y);
}

fn SMAADetectVerticalCornerPattern(edgesTex8: texture_2d<f32>, weights2: ptr<function, vec2<f32>>, texcoord4: vec4<f32>, d3: vec2<f32>) {
    var texcoord5: vec4<f32>;
    var d4: vec2<f32>;
    var leftRight1: vec2<f32>;
    var rounding1: vec2<f32>;
    var factor1: vec2<f32> = vec2<f32>(1.0, 1.0);

    texcoord5 = texcoord4;
    d4 = d3;
    let e20: vec2<f32> = d4;
    let e22: vec2<f32> = d4;
    let e23: vec2<f32> = d4;
    leftRight1 = step(e22, e23.yx);
    let e27: vec2<f32> = leftRight1;
    rounding1 = (e27 * 0.75);
    let e31: vec2<f32> = rounding1;
    let e32: vec2<f32> = leftRight1;
    let e34: vec2<f32> = leftRight1;
    rounding1 = (e31 / vec2<f32>((e32.x + e34.y)));
    let e43: vec2<f32> = factor1;
    let e45: vec2<f32> = rounding1;
    let e47: vec4<f32> = texcoord5;
    let e53: vec4<f32> = texcoord5;
    let e59: vec4<f32> = textureSampleLevel(edgesTex8, linearSampler, e53.xy, 0.0, vec2<i32>(1, 0));
    factor1.x = (e43.x - (e45.x * e59.y));
    let e64: vec2<f32> = factor1;
    let e66: vec2<f32> = rounding1;
    let e68: vec4<f32> = texcoord5;
    let e73: vec4<f32> = texcoord5;
    let e78: vec4<f32> = textureSampleLevel(edgesTex8, linearSampler, e73.zw, 0.0, vec2<i32>(1, 1));
    factor1.x = (e64.x - (e66.y * e78.y));
    let e83: vec2<f32> = factor1;
    let e85: vec2<f32> = rounding1;
    let e87: vec4<f32> = texcoord5;
    let e94: vec4<f32> = texcoord5;
    let e101: vec4<f32> = textureSampleLevel(edgesTex8, linearSampler, e94.xy, 0.0, vec2<i32>(-2, 0));
    factor1.y = (e83.y - (e85.x * e101.y));
    let e106: vec2<f32> = factor1;
    let e108: vec2<f32> = rounding1;
    let e110: vec4<f32> = texcoord5;
    let e117: vec4<f32> = texcoord5;
    let e124: vec4<f32> = textureSampleLevel(edgesTex8, linearSampler, e117.zw, 0.0, vec2<i32>(-2, 1));
    factor1.y = (e106.y - (e108.y * e124.y));
    let e128: vec2<f32> = (*weights2);
    let e134: vec2<f32> = factor1;
    (*weights2) = (e128 * clamp(e134, vec2<f32>(0.0), vec2<f32>(1.0)));
    return;
}

fn SMAABlendingWeightCalculationPS(texcoord6: vec2<f32>, pixcoord_1_: vec2<f32>, offset10: array<vec4<f32>,3u>, edgesTex9: texture_2d<f32>, areaTex_1_3: texture_2d<f32>, searchTex_1_5: texture_2d<f32>, subsampleIndices2: vec4<f32>) -> vec4<f32> {
    var texcoord7: vec2<f32>;
    var pixcoord_1_1: vec2<f32>;
    var offset11: array<vec4<f32>,3u>;
    var subsampleIndices3: vec4<f32>;
    var weights3: vec4<f32> = vec4<f32>(0.0, 0.0, 0.0, 0.0);
    var e14: vec2<f32>;
    var param6: vec2<f32>;
    var param_1_5: vec2<f32>;
    var param_2_1: vec4<f32>;
    var v28: vec2<f32>;
    var param_3_1: vec2<f32>;
    var param_4_1: f32;
    var v29: f32;
    var coords1: vec3<f32>;
    var d5: vec2<f32>;
    var e1_2: f32;
    var param_5_1: vec2<f32>;
    var param_6_1: f32;
    var v30: f32;
    var sqrt_d: vec2<f32>;
    var e2_2: f32;
    var param_7_1: vec2<f32>;
    var param_8_1: f32;
    var param_9_1: f32;
    var param_10_1: f32;
    var v31: vec2<f32>;
    var param_11_1: vec2<f32>;
    var param_12_1: vec4<f32>;
    var param_13_1: vec2<f32>;
    var param_14_1: vec2<f32>;
    var param_15_1: f32;
    var v32: f32;
    var coords_1_1: vec3<f32>;
    var d_1_: vec2<f32>;
    var e1_1_: f32;
    var param_16_1: vec2<f32>;
    var param_17_1: f32;
    var v33: f32;
    var sqrt_d_1_: vec2<f32>;
    var e2_1_: f32;
    var param_18_1: vec2<f32>;
    var param_19_1: f32;
    var param_20_1: f32;
    var param_21_1: f32;
    var v34: vec2<f32>;
    var param_22_1: vec2<f32>;
    var param_23_1: vec4<f32>;
    var param_24_1: vec2<f32>;

    texcoord7 = texcoord6;
    pixcoord_1_1 = pixcoord_1_;
    offset11 = offset10;
    subsampleIndices3 = subsampleIndices2;
    let e28: vec2<f32> = texcoord7;
    let e29: vec4<f32> = textureSample(edgesTex9, linearSampler, e28);
    e14 = e29.xy;
    let e32: vec2<f32> = e14;
    if ((e32.y > 0.0)) {
        {
            let e36: vec2<f32> = texcoord7;
            param6 = e36;
            let e38: vec2<f32> = e14;
            param_1_5 = e38;
            let e40: vec4<f32> = subsampleIndices3;
            param_2_1 = e40;
            let e45: vec2<f32> = param6;
            let e46: vec2<f32> = param_1_5;
            let e47: vec4<f32> = param_2_1;
            let e48: vec2<f32> = SMAACalculateDiagWeights(edgesTex9, areaTex_1_3, e45, e46, e47);
            v28 = e48;
            let e50: vec2<f32> = v28;
            let e52: vec2<f32> = v28;
            let e54: vec4<f32> = weights3;
            let e56: vec4<f32> = weights3;
            weights3 = vec4<f32>(e50.x, e52.y, e54.z, e56.w);
            let e59: vec4<f32> = weights3;
            let e61: vec4<f32> = weights3;
            if ((e59.x == -(e61.y))) {
                {
                    let e66: array<vec4<f32>,3u> = offset11;
                    param_3_1 = e66[0].xy;
                    let e71: array<vec4<f32>,3u> = offset11;
                    param_4_1 = e71[2].x;
                    let e77: f32 = param_4_1;
                    let e78: f32 = SMAASearchXLeft(edgesTex9, searchTex_1_5, (&param_3_1), e77);
                    v29 = e78;
                    let e82: f32 = v29;
                    coords1.x = e82;
                    let e85: array<vec4<f32>,3u> = offset11;
                    coords1.y = e85[1].y;
                    let e90: vec3<f32> = coords1;
                    d5.x = e90.x;
                    let e92: vec3<f32> = coords1;
                    let e95: vec3<f32> = coords1;
                    let e98: vec4<f32> = textureSampleLevel(edgesTex9, linearSampler, e95.xy, 0.0);
                    e1_2 = e98.x;
                    let e102: array<vec4<f32>,3u> = offset11;
                    param_5_1 = e102[0].zw;
                    let e107: array<vec4<f32>,3u> = offset11;
                    param_6_1 = e107[2].y;
                    let e113: f32 = param_6_1;
                    let e114: f32 = SMAASearchXRight(edgesTex9, searchTex_1_5, (&param_5_1), e113);
                    v30 = e114;
                    let e117: f32 = v30;
                    coords1.z = e117;
                    let e119: vec3<f32> = coords1;
                    d5.y = e119.z;
                    let e121: UniformBlock = uniforms;
                    let e124: vec2<f32> = d5;
                    let e126: vec2<f32> = pixcoord_1_1;
                    let e130: UniformBlock = uniforms;
                    let e133: vec2<f32> = d5;
                    let e135: vec2<f32> = pixcoord_1_1;
                    let e140: UniformBlock = uniforms;
                    let e143: vec2<f32> = d5;
                    let e145: vec2<f32> = pixcoord_1_1;
                    let e149: UniformBlock = uniforms;
                    let e152: vec2<f32> = d5;
                    let e154: vec2<f32> = pixcoord_1_1;
                    d5 = abs(round(((e149.rt.zz * e152) + -(e154.xx))));
                    let e161: vec2<f32> = d5;
                    sqrt_d = sqrt(e161);
                    let e164: vec3<f32> = coords1;
                    let e170: vec3<f32> = coords1;
                    let e176: vec4<f32> = textureSampleLevel(edgesTex9, linearSampler, e170.zy, 0.0, vec2<i32>(1, 0));
                    e2_2 = e176.x;
                    let e179: vec2<f32> = sqrt_d;
                    param_7_1 = e179;
                    let e181: f32 = e1_2;
                    param_8_1 = e181;
                    let e183: f32 = e2_2;
                    param_9_1 = e183;
                    let e185: vec4<f32> = subsampleIndices3;
                    param_10_1 = e185.y;
                    let e192: vec2<f32> = param_7_1;
                    let e193: f32 = param_8_1;
                    let e194: f32 = param_9_1;
                    let e195: f32 = param_10_1;
                    let e196: vec2<f32> = SMAAArea(areaTex_1_3, e192, e193, e194, e195);
                    v31 = e196;
                    let e198: vec2<f32> = v31;
                    let e200: vec2<f32> = v31;
                    let e202: vec4<f32> = weights3;
                    let e204: vec4<f32> = weights3;
                    weights3 = vec4<f32>(e198.x, e200.y, e202.z, e204.w);
                    let e208: vec2<f32> = texcoord7;
                    coords1.y = e208.y;
                    let e210: vec4<f32> = weights3;
                    param_11_1 = e210.xy;
                    let e213: vec3<f32> = coords1;
                    param_12_1 = e213.xyzy;
                    let e216: vec2<f32> = d5;
                    param_13_1 = e216;
                    let e221: vec4<f32> = param_12_1;
                    let e222: vec2<f32> = param_13_1;
                    SMAADetectHorizontalCornerPattern(edgesTex9, (&param_11_1), e221, e222);
                    let e223: vec2<f32> = param_11_1;
                    let e225: vec2<f32> = param_11_1;
                    let e227: vec4<f32> = weights3;
                    let e229: vec4<f32> = weights3;
                    weights3 = vec4<f32>(e223.x, e225.y, e227.z, e229.w);
                }
            } else {
                {
                    e14.x = 0.0;
                }
            }
        }
    }
    let e234: vec2<f32> = e14;
    if ((e234.x > 0.0)) {
        {
            let e239: array<vec4<f32>,3u> = offset11;
            param_14_1 = e239[1].xy;
            let e244: array<vec4<f32>,3u> = offset11;
            param_15_1 = e244[2].z;
            let e250: f32 = param_15_1;
            let e251: f32 = SMAASearchYUp(edgesTex9, searchTex_1_5, (&param_14_1), e250);
            v32 = e251;
            let e255: f32 = v32;
            coords_1_1.y = e255;
            let e258: array<vec4<f32>,3u> = offset11;
            coords_1_1.x = e258[0].x;
            let e263: vec3<f32> = coords_1_1;
            d_1_.x = e263.y;
            let e265: vec3<f32> = coords_1_1;
            let e268: vec3<f32> = coords_1_1;
            let e271: vec4<f32> = textureSampleLevel(edgesTex9, linearSampler, e268.xy, 0.0);
            e1_1_ = e271.y;
            let e275: array<vec4<f32>,3u> = offset11;
            param_16_1 = e275[1].zw;
            let e280: array<vec4<f32>,3u> = offset11;
            param_17_1 = e280[2].w;
            let e286: f32 = param_17_1;
            let e287: f32 = SMAASearchYDown(edgesTex9, searchTex_1_5, (&param_16_1), e286);
            v33 = e287;
            let e290: f32 = v33;
            coords_1_1.z = e290;
            let e292: vec3<f32> = coords_1_1;
            d_1_.y = e292.z;
            let e294: UniformBlock = uniforms;
            let e297: vec2<f32> = d_1_;
            let e299: vec2<f32> = pixcoord_1_1;
            let e303: UniformBlock = uniforms;
            let e306: vec2<f32> = d_1_;
            let e308: vec2<f32> = pixcoord_1_1;
            let e313: UniformBlock = uniforms;
            let e316: vec2<f32> = d_1_;
            let e318: vec2<f32> = pixcoord_1_1;
            let e322: UniformBlock = uniforms;
            let e325: vec2<f32> = d_1_;
            let e327: vec2<f32> = pixcoord_1_1;
            d_1_ = abs(round(((e322.rt.ww * e325) + -(e327.yy))));
            let e334: vec2<f32> = d_1_;
            sqrt_d_1_ = sqrt(e334);
            let e337: vec3<f32> = coords_1_1;
            let e343: vec3<f32> = coords_1_1;
            let e349: vec4<f32> = textureSampleLevel(edgesTex9, linearSampler, e343.xz, 0.0, vec2<i32>(0, 1));
            e2_1_ = e349.y;
            let e352: vec2<f32> = sqrt_d_1_;
            param_18_1 = e352;
            let e354: f32 = e1_1_;
            param_19_1 = e354;
            let e356: f32 = e2_1_;
            param_20_1 = e356;
            let e358: vec4<f32> = subsampleIndices3;
            param_21_1 = e358.x;
            let e365: vec2<f32> = param_18_1;
            let e366: f32 = param_19_1;
            let e367: f32 = param_20_1;
            let e368: f32 = param_21_1;
            let e369: vec2<f32> = SMAAArea(areaTex_1_3, e365, e366, e367, e368);
            v34 = e369;
            let e371: vec4<f32> = weights3;
            let e373: vec4<f32> = weights3;
            let e375: vec2<f32> = v34;
            let e377: vec2<f32> = v34;
            weights3 = vec4<f32>(e371.x, e373.y, e375.x, e377.y);
            let e381: vec2<f32> = texcoord7;
            coords_1_1.x = e381.x;
            let e383: vec4<f32> = weights3;
            param_22_1 = e383.zw;
            let e386: vec3<f32> = coords_1_1;
            param_23_1 = e386.xyxz;
            let e389: vec2<f32> = d_1_;
            param_24_1 = e389;
            let e394: vec4<f32> = param_23_1;
            let e395: vec2<f32> = param_24_1;
            SMAADetectVerticalCornerPattern(edgesTex9, (&param_22_1), e394, e395);
            let e396: vec4<f32> = weights3;
            let e398: vec4<f32> = weights3;
            let e400: vec2<f32> = param_22_1;
            let e402: vec2<f32> = param_22_1;
            weights3 = vec4<f32>(e396.x, e398.y, e400.x, e402.y);
        }
    }
    let e405: vec4<f32> = weights3;
    return e405;
}

fn main1() {
    var subsampleIndices4: vec4<f32> = vec4<f32>(0.0, 0.0, 0.0, 0.0);
    var offset12: array<vec4<f32>,3u>;
    var param7: vec2<f32>;
    var param_1_6: vec2<f32>;
    var param_2_2: array<vec4<f32>,3u>;
    var param_3_2: vec4<f32>;

    let e16: vec4<f32> = offset0_1;
    let e17: vec4<f32> = offset1_1;
    let e18: vec4<f32> = offset2_1;
    offset12 = array<vec4<f32>,3u>(e16, e17, e18);
    let e21: vec2<f32> = texcoord1;
    param7 = e21;
    let e23: vec2<f32> = pixcoord1;
    param_1_6 = e23;
    let e25: array<vec4<f32>,3u> = offset12;
    param_2_2 = e25;
    let e27: vec4<f32> = subsampleIndices4;
    param_3_2 = e27;
    let e33: vec2<f32> = param7;
    let e34: vec2<f32> = param_1_6;
    let e35: array<vec4<f32>,3u> = param_2_2;
    let e36: vec4<f32> = param_3_2;
    let e37: vec4<f32> = SMAABlendingWeightCalculationPS(e33, e34, e35, edgesTex, areaTex, searchTex, e36);
    OutColor = e37;
    return;
}

[[stage(fragment)]]
fn main([[location(1)]] offset0_: vec4<f32>, [[location(2)]] offset1_: vec4<f32>, [[location(3)]] offset2_: vec4<f32>, [[location(4)]] texcoord: vec2<f32>, [[location(0)]] pixcoord: vec2<f32>) -> FragmentOutput {
    offset0_1 = offset0_;
    offset1_1 = offset1_;
    offset2_1 = offset2_;
    texcoord1 = texcoord;
    pixcoord1 = pixcoord;
    main1();
    let e34: vec4<f32> = OutColor;
    return FragmentOutput(e34);
}
