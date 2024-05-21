//
//  InstancePayload.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/10/24.
//

import Foundation
import simd

struct InstancePayload {
    var model: simd_float4x4
    var textureCoordinates: simd_float4x2
}
