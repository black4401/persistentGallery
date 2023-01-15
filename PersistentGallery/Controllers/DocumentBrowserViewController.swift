//
//  DocumentBrowserViewController.swift
//  PersistentGallery
//
//  Created by Alexander Angelov on 11.01.23.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    private let path = "Untitled.gallery"
    private let mainStoryboard = "Main"
    private let navigationVC = "DocumentNavigationVC"
    private var template: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        
        template = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true).appending(path: path)
        if let template = template {
            allowsDocumentCreation = FileManager.default.createFile(atPath: template.path,
                                                                    contents: Data())
        }
        
        UINavigationBar.appearance().backgroundColor = .galleryDarkBlue
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
     
        importHandler(template, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        let alert = Alert.create(title: "Failed import file!")
        present(alert, animated: true)
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: mainStoryboard, bundle: nil)
        guard let documentVC = storyBoard.instantiateViewController(withIdentifier: navigationVC) as? UINavigationController else {
            return
        }
        if let galleryVC = documentVC.visibleViewController as? ImageGalleryCollectionViewController {
            galleryVC.galleryDocument = GalleryDocument(fileURL: documentURL)
        }
        documentVC.modalPresentationStyle = .fullScreen
        present(documentVC, animated: true)
    }
}

