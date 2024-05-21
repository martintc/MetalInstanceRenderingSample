//
//  Renderer.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/10/24.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

struct Vertex {
    var position: simd_float3
}


class Renderer: NSObject, MTKViewDelegate {
    
    var device: MTLDevice
    var view: MTKView
    var commandQueue: MTLCommandQueue
    var renderPipelineState: MTLRenderPipelineState
    
    var gameScene: GameScene
    
    init?(metalKitView: MTKView) {
        guard let device = metalKitView.device else {
            fatalError("Unable to acquire device")
        }
        
        self.device = device
        self.view = metalKitView
        
        guard let cq = self.device.makeCommandQueue() else {
            fatalError("Could not make command queue")
        }
        
        self.commandQueue = cq
        
        let mvd = Renderer.buildMetalVertexDescriptor()
        self.renderPipelineState = Renderer.buildRenderPipelineState(device: self.device,
                                                                     view: self.view,
                                                                     mvd: mvd)
        
        self.gameScene = GameScene()
    }
    
    class func buildMetalVertexDescriptor() -> MTLVertexDescriptor {
        let mvd = MTLVertexDescriptor()
        
        mvd.layouts[0].stepFunction = .perVertex
        mvd.layouts[0].stepRate = 1
        mvd.layouts[0].stride = MemoryLayout<SimpleVertex>.stride
        
        mvd.attributes[0].format = .float3
        mvd.attributes[0].bufferIndex = 0
        mvd.attributes[0].offset = MemoryLayout.offset(of: \SimpleVertex.vertex)!
        
        return mvd
    }
    
    class func buildRenderPipelineState(device: MTLDevice,
                                        view: MTKView,
                                        mvd: MTLVertexDescriptor) -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error creating default library")
        }
        
        let rpd: MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        rpd.vertexFunction = library.makeFunction(name: "vertex_shader")
        rpd.fragmentFunction = library.makeFunction(name: "fragment_shader")
        rpd.colorAttachments[0].pixelFormat = view.colorPixelFormat
        do {
            return try device.makeRenderPipelineState(descriptor: rpd)
        } catch let error {
            fatalError("Error making pipeline state: \(error)")
        }
        
    }
    
    func prepareScene() -> MTLBuffer {
        var payloads: [InstancePayload] = []
        
        for type in [Renderable.Quad] {
            for instance in gameScene.renderables[type]! {
                let payload = InstancePayload(model: instance.getModelTransform(),
                                              textureCoordinates: instance.getTextureCoordinates())
                payloads.append(payload)
            }
        }
        
        var memory: UnsafeMutableRawPointer? = nil
        
        let memory_size = payloads.count * MemoryLayout<InstancePayload>.stride
        let page_size = 0x1000
        let allocation_size = (memory_size + page_size - 1) & (~(page_size - 1))
        
        posix_memalign(&memory, page_size, allocation_size)
        memcpy(memory, &payloads, allocation_size)
        
        guard let buffer = device.makeBuffer(bytes: memory!,
                                             length: allocation_size,
                                             options: .storageModeShared) else {
            fatalError("Coould not create buffer in prepare scene")
        }
        
        free(memory)
        
        return buffer
    }
    
    func prepareCamera() -> MTLBuffer {
        var camera = gameScene.camera.getCameraConstants()
        
        guard let buffer = device.makeBuffer(bytes: &camera, length: MemoryLayout<CameraConstants>.stride, options: .storageModeShared) else {
            fatalError("Could not create buffer for camera")
        }
        
        return buffer
    }

    func draw(in view: MTKView) {
        let modelConstants = prepareScene()
        let cameraConstants = prepareCamera()
        
        /// Per frame updates hare
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard let cb = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let rpd = view.currentRenderPassDescriptor else {
            return
        }
        
        guard let re = cb.makeRenderCommandEncoder(descriptor: rpd) else {
            return
        }
        
        re.setRenderPipelineState(renderPipelineState)
        
        // draw calls
        re.setVertexBuffer(Quad.shared.vertexBuffer, offset: 0, index: 0)
        re.setVertexBuffer(modelConstants, offset: 0, index: 1)
        re.setVertexBuffer(cameraConstants, offset: 0, index: 2)
        
        re.setFragmentTexture(TextureLibrary.shared.getTexture("cityTiles").texture, index: 0)
        
        re.drawIndexedPrimitives(type: .triangle,
                                 indexCount: 6,
                                 indexType: .uint16,
                                 indexBuffer: Quad.shared.indexBuffer!,
                                 indexBufferOffset: 0,
                                 instanceCount: gameScene.instanceCounts[.Quad]!)
        
        re.endEncoding()
        cb.present(drawable)
        cb.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
    }
}

// Generic matrix math utility functions
func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                         vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                         vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                         vector_float4(                  0,                   0,                   0, 1)))
}

func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                         vector_float4(0, 1, 0, 0),
                                         vector_float4(0, 0, 1, 0),
                                         vector_float4(translationX, translationY, translationZ, 1)))
}

func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
                                         vector_float4( 0, ys, 0,   0),
                                         vector_float4( 0,  0, zs, -1),
                                         vector_float4( 0,  0, zs * nearZ, 0)))
}

func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}
