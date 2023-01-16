//
//  ImageGalleryModel.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 9.12.22.
//

import Foundation
import UIKit

struct ImageModel: Hashable, Codable {
    
    var id = UUID()
    var url: URL
    var aspectRatio: CGFloat
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
        lhs.id == rhs.id
    }
}


