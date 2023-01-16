//
//  FolderModel.swift
//  Persistent Gallery
//
//  Created by Alexander Angelov on 17.01.23.
//

import Foundation

struct FolderModel: Hashable {
    
    var id = UUID()
    var images: [ImageModel] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: FolderModel, rhs: FolderModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension FolderModel: Codable {
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let value = try? JSONDecoder().decode(FolderModel.self, from: json) {
            self = value
        } else {
            return nil
        }
    }
    
}
