//
//  UserWindowController.swift
//  Drip
//
//  Created by David Wu on 9/21/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class UserWindowController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var profileImageView: NSImageView!
    @IBOutlet weak var relationshipButton: NSButton!

    var userId: String!
    var model: InstagramModel!
    @objc dynamic var user = UserViewModel()
    private var normalRelationshipTitle: String!
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "UserWindowController")
    }

    override func windowDidLoad() {
        profileImageView.layer?.cornerRadius = 30.0
        relationshipButton.addTrackingArea(NSTrackingArea(rect: relationshipButton.bounds,
                                                          options: [.activeAlways, .mouseEnteredAndExited],
                                                          owner: self,
                                                          userInfo: nil))
        collectionView.register(ImageCollectionViewItem.self,
                                forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "image"))
    }

    override func mouseEntered(with event: NSEvent) {
        normalRelationshipTitle = relationshipButton.title
        switch user.relationship {
        case InstagramRelationshipOut.follows.bindingValue:   relationshipButton.title = "Unfollow"
        case InstagramRelationshipOut.none.bindingValue:      break
        case InstagramRelationshipOut.requested.bindingValue: relationshipButton.title = "Cancel"
        default: fatalError("Unknown binding value '\(user.relationship) for `InstagramRelationshipOut`")
        }
    }

    override func mouseExited(with event: NSEvent) {
        relationshipButton.title = normalRelationshipTitle
    }

    func windowDidBecomeKey(_ notification: Notification) {
        model.updateUser(userId, user)
    }

    @IBAction func toggleFollow(_ sender: NSButton) {
        let relationship = InstagramRelationshipOut(bindingValue: user.relationship)
        model.toggleFollow(userId, currentRelationship: relationship)
    }
}
