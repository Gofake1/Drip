//
//  ImageCollectionViewItem.swift
//  Drip
//
//  Created by David Wu on 9/21/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {
    override var nibName: NSNib.Name? {
        return NSNib.Name(rawValue: "ImageCollectionViewItem")
    }
}
