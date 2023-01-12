//
//  ImageGalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 5.12.22.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    static var defaultWidth: CGFloat = 139
    
    @IBOutlet weak var thumbnailView: UIImageView!
    
    var imageURL: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noImageLabel.attributedText = NSAttributedString("NO IMAGE")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noImageLabel.attributedText = NSAttributedString("NO IMAGE")
    }
    
    @IBOutlet weak var noImageLabel: UILabel!
    
    var cellImage: UIImage? {
        didSet {
            guard let cellImage = cellImage else {
                noImageLabel.isHidden = false
                thumbnailView.isHidden = true
                return
            }
            thumbnailView.image = nil
            thumbnailView.image = cellImage
            thumbnailView.isHidden = false
            noImageLabel.isHidden = true
        }
    }
}

