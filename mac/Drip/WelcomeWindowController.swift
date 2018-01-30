//
//  WelcomeWindowController.swift
//  Drip
//
//  Created by David Wu on 9/7/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

private let authURL = URL(string: "https://api.instagram.com/oauth/authorize/?client_id=24dad3650cf344ab8eca674697394dd2&redirect_uri=https%3A%2F%2Fdrip.gofake1.net/auth&response_type=code&scope=basic+public_content+follower_list+comments+relationships+likes")!

class WelcomeWindowController: NSWindowController {
    @IBOutlet weak var instructionsView: NSView!
    @IBOutlet weak var confirmationView: NSView!
    @IBOutlet weak var usernameLabel: NSTextField!
    @IBOutlet weak var fullnameLabel: NSTextField!
    @IBOutlet weak var profilePictureView: NSImageView!

    var onWelcomeCompletion: (() -> Void)?

    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "WelcomeWindowController")
    }

    override func windowDidLoad() {
        window?.contentView?.addSubview(confirmationView)
        confirmationView.frame = instructionsView.frame
        confirmationView.isHidden = true
    }

    @IBAction func cancelConfirmation(_ sender: NSButton) {
        confirmationView.isHidden = true
        instructionsView.isHidden = false
    }

    @IBAction func okConfirmation(_ sender: NSButton) {
        close()
        onWelcomeCompletion?()
    }

    @IBAction func goToAuthorizationWebpage(_ sender: NSButton) {
        NSWorkspace.shared.open(authURL)
    }

    func displayConfirmation(_ username: String?, _ fullname: String?, _ profilePicture: NSImage?) {
        usernameLabel.stringValue = "@"+(username ?? "unknown")
        fullnameLabel.stringValue = fullname ?? "Unknown"
        if let profilePicture = profilePicture {
            profilePictureView.image = profilePicture
        }

        instructionsView.isHidden = true
        confirmationView.isHidden = false
    }
}
