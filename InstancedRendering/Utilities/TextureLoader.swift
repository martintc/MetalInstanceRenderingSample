//
//  TextureLoader.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/14/24.
//

import Foundation
import Metal
import MetalKit

class TextureLoader {
    
    static let shared = TextureLoader()
    
    private var loader: MTKTextureLoader
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Issue creating default device in TextureLoader")
        }
        
        self.loader = MTKTextureLoader(device: device)
    }
    
    func loadTexture(sourceName: String) -> MTLTexture? {
        do {
            let texture = try self.loader.newTexture(name: sourceName,
                                                     scaleFactor: 1.0,
                                                     bundle: Bundle.main,
                                                     options: [MTKTextureLoader.Option.textureStorageMode: 0])
            
            return texture
        } catch let error {
            print("Error: \(error)")
        }
        
        return nil
    }
}
