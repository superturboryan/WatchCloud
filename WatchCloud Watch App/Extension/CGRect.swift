//
//  CGRect.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-05.
//

import Foundation

extension CGSize {
    func scaled(_ scale: CGFloat) -> CGSize {
        let newWidth = self.width * scale
        let newHeight = self.height * scale
        return CGSize(width: newWidth, height: newHeight)
    }
}
