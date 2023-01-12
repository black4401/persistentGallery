//
//  ImageView.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 29.12.22.
//

import UIKit

class ImageView: UIView {
    
    var cellImage: UIImage? {
        didSet {
            let size = cellImage?.size ?? CGSize.zero
            frame = CGRect(origin: CGPoint.zero, size: size)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        cellImage?.draw(in: bounds)
    }
}
