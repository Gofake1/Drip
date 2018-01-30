//
//  FeedWindowController.swift
//  Drip
//
//  Created by David Wu on 9/17/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class FeedWindowController: NSWindowController {
    enum ItemSize {
        case small
        case medium
        case large

        var cgSize: CGSize {
            switch self {
            case .small:  return CGSize(width: 80, height: 80)
            case .medium: return CGSize(width: 160, height: 160)
            case .large:  return CGSize(width: 240, height: 240)
            }
        }
    }

    @IBOutlet weak var collectionView: NSCollectionView!

    @objc var feed = FeedViewModel()
    var model: InstagramModel!
    private var itemSize = ItemSize.small {
        didSet {
            if itemSize != oldValue {
                guard let window = window else { return }
                collectionView.collectionViewLayout?.invalidateLayout()
                window.contentResizeIncrements = CGSize(width: itemSize.cgSize.width, height: 1)
                switch itemSize {
                case .small: fallthrough
                case .medium:
                    window.minSize = CGSize(width: 160, height: 182)
                case .large:
                    window.minSize = CGSize(width: 240, height: 262)
                }
                window.resizeToFitContentResizingIncrements()
            }
        }
    }
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "FeedWindowController")
    }

    override func windowDidLoad() {
        window?.contentResizeIncrements = CGSize(width: ItemSize.small.cgSize.width, height: 1)
        collectionView.register(PostCollectionViewItem.self,
                                forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "post"))
    }

    @IBAction func setItemSize(_ sender: NSMenuItem) {
        sender.menu?.items.forEach { $0.state = .off }
        sender.state = .on
        switch sender.tag {
        case 0: itemSize = .small
        case 1: itemSize = .medium
        case 2: itemSize = .large
        default: fatalError("Unknown item size for tag \(sender.tag)")
        }
    }
}

extension FeedWindowController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        return itemSize.cgSize
    }
}

extension FeedWindowController: NSWindowDelegate {
    func windowDidBecomeKey(_ notification: Notification) {
        model.updateFeed(feed)
    }
}
