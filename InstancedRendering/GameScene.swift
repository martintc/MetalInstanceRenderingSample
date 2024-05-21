//
//  GameScene.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/10/24.
//

import Foundation
import MetalKit

class GameScene {
    var renderables: [Renderable: [Entity]]
    var instanceCounts: [Renderable: Int]
    
    var camera: OrthographicCamera
    
    init() {
        renderables = [Renderable: [Entity]]()
        
        renderables[.Quad] = []
        
        instanceCounts = [Renderable: Int]()
        
        instanceCounts[.Quad] = 0
        
        self.camera = OrthographicCamera(left: -20, right: 20, bottom: -20, top: 20, near: 0.1, far: 100)
        self.camera.setPosition(to: simd_float3(0, 0, 0))
        
        load()
    }
    
    func load() {
        loadTextures()
        loadMeshes()
    }
    
    func loadMeshes() {
        
        let entities = TileMapLoader.loadTileMap(mapName: "testmap", startId: 0, textureName: "cityTiles")
        
        for entity in entities {
            renderables[.Quad]?.append(entity)
            instanceCounts[.Quad]! += 1
        }
    }
    
    func loadTextures() {
        _ = TextureLibrary.shared.loadTileAtlasIntoLibrary(sourceName: "tilemap_packed", textureName: "cityTiles", spriteWidth: 8, spriteHeight: 8)
    }
    
    private func addQuad(position: simd_float3, id: Int32, color: simd_float3) {
        let entity = Entity(position: position,
                            id: id,
                            color: color)
        
        entity.texture = "cityTiles"
        entity.setTextureCoordinates(row: 5, column: 5)
        
        renderables[.Quad]?.append(entity)
        
        instanceCounts[.Quad]! += 1
    }
}
