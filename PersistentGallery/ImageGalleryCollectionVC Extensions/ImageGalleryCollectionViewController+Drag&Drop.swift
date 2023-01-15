//
//  ImageGalleryCollectionViewController+Drag&Drop.swift
//  PersistentGallery
//
//  Created by Alexander Angelov on 13.01.23.
//

import UIKit

extension ImageGalleryCollectionViewController {
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        guard (collectionView.cellForItem(at: indexPath) is ImageGalleryCollectionViewCell) else { return [] }
        
        indexPathsForDragging.append(indexPath)
        let imageURL = imageCollection.images[indexPath.item].url as NSURL
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: imageURL))
        dragItem.localObject = imageURL
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        session.localContext = collectionView
        indexPathsForDragging = []
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        if isSelf {
            return session.canLoadObjects(ofClass: NSURL.self)
        } else {
            return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = session.localDragSession?.localContext as? UICollectionView == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    private func performDropFromOutside(_ coordinator: UICollectionViewDropCoordinator, _ item: UICollectionViewDropItem, _ destinationIndexPath: IndexPath) {
        
        let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "Placeholder Identifier"))
        
        let imageLoadingGroup = DispatchGroup()
        
        var imageURL: URL?
        var image: UIImage?
        
        imageLoadingGroup.enter()
        item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (itemProvider, error) in
            if let url = itemProvider as? URL {
                imageURL = url
                
                let currentURL = try? Data(contentsOf: url)
                if let imageData = currentURL {
                    image = UIImage(data: imageData)
                } else {
                    placeholderContext.deletePlaceholder()
                }
            } else {
                placeholderContext.deletePlaceholder()
            }
            imageLoadingGroup.leave()
        }
        
        imageLoadingGroup.enter()
        item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (itemProvider, error) in
            if let loadedImage = itemProvider as? UIImage {
                image = loadedImage
            } else {
                placeholderContext.deletePlaceholder()
            }
            imageLoadingGroup.leave()
        }
        
        imageLoadingGroup.notify(queue: DispatchQueue.main) { [weak self] in
            let aspectRatio = image!.size.height / image!.size.width
            let imageData = ImageModel(url: imageURL!, aspectRatio: aspectRatio) // image: image!,
            
            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                self?.imageCollection.images.insert(imageData, at: insertionIndexPath.item)
                print("Inserting date to model: \(imageData.url)")
            })
        }
    }
    
    private func performDropFromInside(_ item: UICollectionViewDropItem, _ sourceIndexPath: IndexPath, _ collectionView: UICollectionView, _ destinationIndexPath: IndexPath, _ coordinator: UICollectionViewDropCoordinator) {
        
        if item.dragItem.localObject is URL {
            
            collectionView.performBatchUpdates {
                if imageCollection.images.count > 1 {
                    collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                    imageCollection.images.move(from: sourceIndexPath.item, to: destinationIndexPath.item)
                }
            }
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let item = collectionView.numberOfItems(inSection: 0)
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: item, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                performDropFromInside(item, sourceIndexPath, collectionView, destinationIndexPath, coordinator)
            } else {
                performDropFromOutside(coordinator, item, destinationIndexPath)
            }
        }
    }
}
