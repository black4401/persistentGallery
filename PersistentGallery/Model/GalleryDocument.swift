//
//  GalleryDocument.swift
//  PersistentGallery
//
//  Created by Alexander Angelov on 11.01.23.
//

import UIKit

class GalleryDocument: UIDocument {
    
    var gallery: FolderModel?
    var thumbnail: UIImage?
    
    override func contents(forType typeName: String) throws -> Any {
        return gallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let json = contents as? Data else {
            return
        }
        gallery = FolderModel(json: json)
        
        if gallery == nil {
            gallery = FolderModel(images: [])
        }
    }
    
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey: thumbnail]
        }
        return attributes
    }
}

