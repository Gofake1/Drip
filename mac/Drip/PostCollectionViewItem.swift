//
//  PostCollectionViewItem.swift
//  Drip
//
//  Created by David Wu on 9/20/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PostCollectionViewItem: NSCollectionViewItem {
    override var nibName: NSNib.Name? {
        return NSNib.Name(rawValue: "PostCollectionViewItem")
    }

    @IBAction func showUser(_ sender: NSClickGestureRecognizer) {
        guard let vm = representedObject as? FeedItemViewModel else { fatalError() }
        (NSApp.delegate as? AppDelegate)?.showUser(vm.userId)
    }
}
