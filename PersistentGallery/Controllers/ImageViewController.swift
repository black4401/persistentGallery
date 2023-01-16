//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 9.12.22.
//

import UIKit

class ImageViewController: UIViewController {
    
    private enum ScrollViewConstants {
        static let minimumZoom: CGFloat = 1
        static let maximumZoom: CGFloat = 4
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!
    
    func centerImageInView() {
        imageView.contentMode = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        setupScrollView()
        centerImageInView()
    }
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = ScrollViewConstants.minimumZoom
        scrollView.maximumZoomScale = ScrollViewConstants.maximumZoom
        scrollView.delegate = self
    }
}
extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
