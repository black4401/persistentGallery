//
//  SecondaryViewController.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 9.12.22.
//

import Foundation
import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate  {
    
    var imageCollection: FolderModel = FolderModel()
    var galleryDocument: GalleryDocument?
    private var indexPathsForDragging: [IndexPath] = []
    var cellScale: CGFloat = 1.0
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @IBOutlet weak var saveButton: UINavigationItem!
    @IBAction func clickSave(_ sender: UIBarButtonItem) {
        save()
        dismiss(animated: true) {
            self.galleryDocument?.close()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        addPinchGesture()
        openGalleryDocument()
        
//        let alert = Alert.create(title: "Failed import file!")
//        present(alert, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout?.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return imageCollection.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image Cell", for: indexPath)
        if let cell = cell as? ImageGalleryCollectionViewCell {
            addTapGestures(to: cell)
            updateCellImage(cell: cell, indexPath: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let imageAspectRatio = imageCollection.images[indexPath.item].aspectRatio
        let cellWidth = ImageGalleryCollectionViewCell.defaultWidth * cellScale
        let cellHeight = cellWidth * imageAspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    //DRAG AND DROP METHODS
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
    private func updateCellImage(cell: ImageGalleryCollectionViewCell, indexPath: IndexPath) {
        
        let imageURL = imageCollection.images[indexPath.item].url
//        let imageData = try? Data(contentsOf: imageURL)
        
        cell.configure(with: imageURL) {
            self.showNoImageAlert(at: indexPath)
        }
        
//        guard let image = UIImage(data: imageData!) else {
//            return
//        }
//        cell.cellImage = image
//        cell.imageURL = imageURL
//        cell.configure(with: imageURL) {
//            self.showNoImageAlert(at: indexPath)
//        }
        
    }
}

extension ImageGalleryCollectionViewController {
    
    private func save() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        let firstCell = collectionView.cellForItem(at: firstIndexPath) as? ImageGalleryCollectionViewCell
        let image = firstCell?.thumbnailView.image
        galleryDocument?.thumbnail = image
        galleryDocument?.gallery = imageCollection
        galleryDocument?.updateChangeCount(.done)
    }
    
    func openGalleryDocument() {
        galleryDocument?.open { [weak self] success in
            guard success else {
                return
            }
            self?.imageCollection = (self?.galleryDocument?.gallery)!
            self?.title = self?.galleryDocument?.localizedName
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self?.navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
    }
    func showNoImageAlert(at indexPath: IndexPath) {
        imageCollection.images.remove(at: indexPath.row)
        let okAction = Alert.createAction(.ok)
            let actions = [okAction]
            let alert = Alert.create(title: "Could not load image.", actions: actions)
            present(alert, animated: true)
    }
}


