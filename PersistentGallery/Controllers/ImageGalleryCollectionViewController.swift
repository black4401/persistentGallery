//
//  SecondaryViewController.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 9.12.22.
//

import Foundation
import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var imageCollection: FolderModel = FolderModel()
    var galleryDocument: GalleryDocument?
    var indexPathsForDragging: [IndexPath] = []
    var cellScale: CGFloat = Constants.cellScale
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @IBOutlet weak var saveButton: UINavigationItem!
    
    @IBAction func clickSave(_ sender: UIBarButtonItem) {
        clickSave()
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
        collectionView.backgroundColor = .galleryLightBlue
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.tintColor = .black
        UINavigationBar.appearance().backgroundColor = .galleryDarkBlue
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clickSave()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return imageCollection.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier, for: indexPath)
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
}

extension ImageGalleryCollectionViewController {
    
    private func clickSave() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        let firstCell = collectionView.cellForItem(at: firstIndexPath) as? ImageGalleryCollectionViewCell
        let image = firstCell?.thumbnailView.image
        galleryDocument?.thumbnail = image
        galleryDocument?.gallery = imageCollection
        galleryDocument?.updateChangeCount(.done)
    }
    
    private func updateCellImage(cell: ImageGalleryCollectionViewCell, indexPath: IndexPath) {
        let imageURL = imageCollection.images[indexPath.item].url
        
        cell.configure(with: imageURL) {
            self.showNoImageAlert(at: indexPath)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = try? Data(contentsOf: imageURL)
            
            DispatchQueue.main.async {
                cell.cellImage = UIImage(data: imageData!)
            }
        }
    }
    
    private func openGalleryDocument() {
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
    
    private  func showNoImageAlert(at indexPath: IndexPath) {
        imageCollection.images.remove(at: indexPath.row)
        let okAction = Alert.createAction(.ok)
        let actions = [okAction]
        let alert = Alert.create(title: Constants.imageAlertMSG, actions: actions)
        present(alert, animated: true)
    }
}


