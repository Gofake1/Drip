//
//  NSWindow+.swift
//  Drip
//
//  Created by David Wu on 9/29/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import AppKit

extension NSWindow {
    /// Resizes window considering `minSize` and `contentResizingIncrements`.
    /// - postcondition: Mutates `frame`.
    func resizeToFitContentResizingIncrements() {
        let width = Int(frame.size.width)
        let height = Int(frame.size.height)
        var newSize = frame.size
        if width < Int(minSize.width) {
            newSize.width = minSize.width
        } else {
            let diff = width % Int(contentResizeIncrements.width)
            newSize.width = frame.width - CGFloat(diff)
        }
        if height < Int(minSize.height) {
            newSize.height = minSize.height
        }
        setFrame(CGRect(origin: frame.origin, size: newSize), display: true, animate: true)
    }
}
