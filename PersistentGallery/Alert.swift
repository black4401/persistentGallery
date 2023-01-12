//
//  Alert.swift
//  PersistentGallery
//
//  Created by Alexander Angelov on 11.01.23.
//

import UIKit

struct Alert {
    enum Action {
        case ok
        case dontShowAgain
    }
    //var handler = ((UIAlertAction) -> ()).self
    
    static func createAction(_ action: Action) -> UIAlertAction {
        switch action {
        case .ok:
                return UIAlertAction(title: "OK", style: .default, handler: nil)
        case .dontShowAgain:
                return UIAlertAction(title: "Don't show again", style: .destructive, handler: nil)
        }
    }
    
    static func create(title: String? = nil,
                       message: String? = nil,
                       preferredStyle: UIAlertController.Style = .alert,
                       actions: [UIAlertAction] = [createAction(.ok)]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            alert.addAction(action)
        }
        return alert
    }
}
