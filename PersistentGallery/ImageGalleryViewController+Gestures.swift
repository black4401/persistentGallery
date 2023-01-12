//
//  ImageGalleryViewController+Gestures.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 29.12.22.
//

import Foundation
import UIKit

extension ImageGalleryCollectionViewController {

    func addPinchGesture() {
        let pinch = UIPinchGestureRecognizer(
            target: self,
            action: #selector(pinch(recognizer:))
        )
        collectionView.addGestureRecognizer(pinch)
    }

    @objc private func pinch(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            cellScale = recognizer.scale
            flowLayout?.invalidateLayout()
        case .ended:
            if cellScale != 1.0 {
                ImageGalleryCollectionViewCell.defaultWidth *= cellScale
                cellScale = 1.0
                collectionView.reloadData()
            }
        default:
            return
        }
    }

    func addTapGestures(to cell: ImageGalleryCollectionViewCell) {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tap(recognizer:))
        )
        cell.addGestureRecognizer(tapGesture)
    }

    @objc private func tap(recognizer: UITapGestureRecognizer) {
        if let indexPath = collectionView.indexPathForItem(at: recognizer.location(in: collectionView)) {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageGalleryCollectionViewCell

            performSegue(withIdentifier: "Show Image", sender: cell.cellImage)
        }
    }
}

extension ImageGalleryCollectionViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Image" {
            if let imageVC = segue.destination as? ImageViewController,
                let image = sender as? UIImage {
                imageVC.image = image
            }
        }
    }
}
