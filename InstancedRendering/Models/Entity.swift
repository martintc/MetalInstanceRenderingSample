//
//  Entity.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/10/24.
//

import Foundation
import simd

class Entity {
    var position: simd_float3
    var id: Int32
    var color: simd_float3
    var scale: Float = 1
    var textureCoordinates: simd_float4x2? = nil
    var texture: String = ""
    
    init(position: simd_float3, id: Int32, color: simd_float3) {
        self.position = position
        self.id = id
        self.color = color
    }
    
    func getTextureCoordinates() -> simd_float4x2 {
        guard let texCoords = textureCoordinates else {
            return simd_float4x2()
        }
        
        return texCoords
    }
    
    func setTextureCoordinates(_ matrix: simd_float4x2) {
        self.textureCoordinates = matrix
    }
    
    func setTextureCoordinates(row: Int, column: Int) {
        let texture = TextureLibrary.shared.getTexture(self.texture)
        
        self.textureCoordinates = texture.getTileCoordiantesByLocation(row: Float(row), column: Float(column))
    }
    
    func setTextureCoordinates(id: Int) {
        let texture = TextureLibrary.shared.getTexture(self.texture)
        
        self.textureCoordinates = texture.getTileCoordinatesById(id: id)
    }
    
    func getModelTransform() -> simd_float4x4 {
        var model = matrix_identity_float4x4
        
        var scaleMatrix = matrix_identity_float4x4
        scaleMatrix[0][0] = scale
        scaleMatrix[1][1] = scale
        scaleMatrix[2][2] = scale
        
        model = model * matrix4x4_translation(self.position.x, self.position.y, self.position.z)
        model = model * scaleMatrix
        return model
    }
}
