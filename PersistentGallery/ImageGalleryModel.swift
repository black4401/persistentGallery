//
//  ImageGalleryModel.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 9.12.22.
//

import Foundation
import UIKit

struct ImageModel: Hashable {
    
    var id = UUID()
    var url: URL
    //var image: UIImage?
    var aspectRatio: CGFloat
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
        lhs.id == rhs.id
    }
}
extension ImageModel: Codable {
    
}

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

