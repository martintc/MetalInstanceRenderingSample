//
//  OrthographicCamera.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/12/24.
//

import Foundation
import simd

class OrthographicCamera: Entity {
    
    var projectionMatrix: simd_float4x4 = matrix_identity_float4x4
    var viewMatrix: simd_float4x4 = matrix_identity_float4x4
    
    var rotation: simd_float1 = 0
    
    var aspectRatio: Float = 0
    
    init(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
        
        projectionMatrix[0][0] = 2 / (right - left)
        projectionMatrix[0][1] = 0
        projectionMatrix[0][2] = 0
        projectionMatrix[0][3] = -(right + left) / (right - left)
        
        projectionMatrix[1][0] = 0
        projectionMatrix[1][1] = 2 / (top - bottom)
        projectionMatrix[1][2] = 0
        projectionMatrix[1][3] = -(top + bottom) / (top - bottom)
        
        projectionMatrix[2][0] = 0
        projectionMatrix[2][1] = 0
        projectionMatrix[2][2] = -2 / (far - near)
        projectionMatrix[2][3] = -(far + near) / (far - near)
        
        projectionMatrix[3][0] = 0
        projectionMatrix[3][1] = 0
        projectionMatrix[3][2] = 0
        projectionMatrix[3][3] = 1
        
        super.init(position: simd_float3(0, 0, 0), id: 0, color: simd_float3(0x00, 0x00, 0x00))
    }
    
    func setRotation(by rotation: Float) {
        self.rotation = rotation
        recalculateViewMatrix()
    }
    
    func setPosition(to vector: simd_float3) {
        self.position = vector
        recalculateViewMatrix()
    }
    
    func getPosition() -> simd_float3 {
        self.position
    }
    
    func getRotation() -> Float {
        self.rotation
    }
    
    private func recalculateViewMatrix() {
        let transform: simd_float4x4 = matrix4x4_translation(self.position.x, self.position.y, self.position.z)
        self.viewMatrix = transform.inverse
    }
    
    func getProjectionViewMatrix() -> simd_float4x4 {
        return projectionMatrix * viewMatrix
    }
    
    func getProjectionMatrix() -> simd_float4x4 {
        self.projectionMatrix
    }
    
    func getViewMatrix() -> simd_float4x4 {
        self.viewMatrix
    }
    
    func getCameraConstants() -> CameraConstants {
        return CameraConstants(projectionMatrix: projectionMatrix, viewMatrix: viewMatrix)
    }
    
    func setAspectRatio(width: Float, height: Float) {
        self.aspectRatio = width / height
    }
    
    func getAspectRatio() -> Float {
        self.aspectRatio
    }
    
}
