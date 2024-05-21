//
//  TIleMapLoader.swift
//  InstancedRendering
//
//  Created by Todd Martin on 5/20/24.
//

import Foundation
import simd

class TileMapLoader {
    
    static func loadTileMap(mapName: String, startId: Int32, textureName: String) -> [Entity] {
        var entities = [Entity]()
        var contents: String
        var startId = startId
        
        // load in file
        guard let path = Bundle.main.path(forResource: mapName, ofType: "csv") else {
            return entities
        }
        
         // read in contents of file
        do {
            contents = try String(contentsOfFile: path)
        } catch {
            return entities
        }
        
        // split by newline character
        let rows = contents.components(separatedBy: "\n")
        var rowPointer = Float(rows.count / 2)
        
        for row in rows {
            if row.isEmpty {
                break
            }
            
            let columns = row.components(separatedBy: ",")
            var columnPointer = Float(columns.count / 2) * -1
            for index in columns {
                guard let id = Int(index) else {
                    fatalError("Could not cast id to an integer")
                }
                
                let entity = Entity(position: simd_float3(columnPointer, rowPointer, 0), id: startId, color: simd_float3(0, 0, 0))
                entity.texture = textureName
                entity.setTextureCoordinates(id: id)
                entities.append(entity)
                
                startId += 1
                columnPointer += 1
            }
            rowPointer -= 1
        }
        
        
        return entities
    }
}
