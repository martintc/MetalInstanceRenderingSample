//
//  Shaders.metal
//  InstancedRendering
//
//  Created by Todd Martin on 5/10/24.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct {
    float3 position [[attribute((0))]];
} Vertex;

typedef struct {
    float4 position[[position]];
    float3 color;
    float2 textCoords;
} VertexOut;

typedef struct {
    float4x4 model;
    float4x2 textCoords;
} InstancePayload;

//typedef struct {
//    float4x4 viewProjectionMatrix;
//} CameraConstants;

typedef struct {
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
} CameraConstants;

vertex VertexOut vertex_shader(
    const device Vertex *vertices [[buffer(0)]],
    unsigned int vid [[vertex_id]],
    unsigned int iid [[instance_id]],
    const device InstancePayload *payloads [[buffer(1)]],
    const device CameraConstants &camera [[buffer(2)]])
{
    VertexOut out;
    Vertex in = vertices[vid];
    InstancePayload ip = payloads[iid];
    out.position = camera.projectionMatrix * camera.viewMatrix * ip.model * float4(in.position, 1);
    out.textCoords = ip.textCoords[vid];
    return out;
}

fragment float4 fragment_shader(VertexOut in [[stage_in]], texture2d<float> colorTexture [[texture(0)]])
{
    const sampler colorSampler(mip_filter::nearest, mag_filter::nearest, min_filter::nearest);
    float4 texture = colorTexture.sample(colorSampler, float2(in.textCoords[0], in.textCoords[1]));
    return float4(texture.rgba);
}
