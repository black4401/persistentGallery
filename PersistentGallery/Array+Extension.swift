//
//  Array+Extension.swift
//  ImageGallery
//
//  Created by Alexander Angelov on 3.01.23.
//

import Foundation

extension Array {
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}
