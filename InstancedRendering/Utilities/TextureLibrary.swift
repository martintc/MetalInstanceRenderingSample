//
//  TextureLibrary.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/14/24.
//

import Foundation
import MetalKit

class TextureLibrary {
    static let shared = TextureLibrary()
    
    private var library: [String: Texture]
    
    init() {
        self.library = [String: Texture]()
    }
    
    func getTexture(_ textureName: String) -> Texture {
        guard let texture = self.library[textureName] else {
            fatalError("Could not get tetxure")
        }
        
        return texture
    }
    
    func loadTileAtlasIntoLibrary(sourceName: String, textureName: String, spriteWidth: Float, spriteHeight: Float) -> Bool {
        if sourceName.isEmpty || textureName.isEmpty {
            return false
        }
        
        guard let mtlTexture = TextureLoader.shared.loadTexture(sourceName: sourceName) else {
            return false
        }
        
        let texture = Texture(texture: mtlTexture, spriteWidth: spriteWidth, spriteHeight: spriteHeight)
        
        self.library[textureName] = texture
        
        return true
    }
    
    func loadTextureIntoLibrary(sourceName: String, textureName: String) -> Bool {
        if sourceName.isEmpty || textureName.isEmpty {
            return false
        }
        
        guard let mtlTexture = TextureLoader.shared.loadTexture(sourceName: sourceName) else {
            return false
        }
        
        let texture = Texture(texture: mtlTexture)
        
        self.library[textureName] = texture
        
        return true
    }
}
