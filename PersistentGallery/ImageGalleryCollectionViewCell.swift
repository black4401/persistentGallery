//
//  ImageGalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 5.12.22.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    static var defaultWidth: CGFloat = 139
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    var imageURL: URL?
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noImageLabel.attributedText = NSAttributedString("NO IMAGE")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noImageLabel.attributedText = NSAttributedString("NO IMAGE")
        thumbnailView.image = nil
    }
    
    func configure(with imageURL: URL, _ completion: @escaping () -> ()) {
        thumbnailView.image = nil
        
        activityIndicator.startAnimating()
        
        ImageCache.shared.loadOrCacheImage(from: imageURL) { [weak self] imageFromCache, url in
            
            self?.activityIndicator.stopAnimating()
            
            guard url == imageURL,
                  let imageFromCache = imageFromCache else {
                completion()
                return
            }
            self?.thumbnailView.image = imageFromCache
        }
    }
}

