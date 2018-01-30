//
//  AppDelegate.swift
//  Drip
//
//  Created by David Wu on 9/2/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa
import Security

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var model: InstagramModel!
    private lazy var welcomeWC = WelcomeWindowController()
    private lazy var myFeedWC: FeedWindowController = {
        let wc = FeedWindowController()
        wc.model = model
        return wc
    }()
    private var userWCs = [String: UserWindowController]()

    override init() {
        super.init()
        let instagramRelationshioOutToString = InstagramRelationshipOutToStringTransformer()
        ValueTransformer.setValueTransformer(instagramRelationshioOutToString,
            forName: NSValueTransformerName(rawValue: "InstagramRelationshipOutToString"))
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize with the local access token and user ID, otherwise start the setup process
        if let token = getAuthToken(), let id = UserDefaults.standard.string(forKey: "myId") {
            model = InstagramModel(token, id)
            myFeedWC.showWindow(nil)
        } else {
            NSAppleEventManager.shared()
                .setEventHandler(self,
                                 andSelector: #selector(AppDelegate.handleURLEvent(_:_:)),
                                 forEventClass: AEEventClass(bitPattern: Int32(kInternetEventClass)),
                                 andEventID: AEEventID(bitPattern: Int32(kAEGetURL)))
            welcomeWC.onWelcomeCompletion = { [weak self] in self?.myFeedWC.showWindow(nil) }
            welcomeWC.showWindow(nil)
        }
    }

    @IBAction func showMyself(_ sender: NSMenuItem) {
        showUser(model.myId)
    }

    @IBAction func showMyFeed(_ sender: NSMenuItem) {
        guard model != nil else { return }
        myFeedWC.showWindow(nil)
    }

    func showUser(_ id: String) {
        if let wc = userWCs[id] {
            wc.showWindow(nil)
        } else {
            let wc = UserWindowController()
            wc.userId = id
            wc.model = model
            userWCs[id] = wc
            wc.showWindow(nil)
        }
    }

    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, _ replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let url = URL(string: urlString),
            let host = url.host
            else { return }
        switch host {
        case "auth":
            break
        default:
            return
        }
        guard let query = url.query else { return }
        var queryDict = [String: String]()
        for param in query.split(separator: "&") {
            let tokens = param.split(separator: "=")
            guard tokens.count == 2 else { continue }
            queryDict[String(tokens[0])] = String(tokens[1]).removingPercentEncoding
        }
        switch host {
        case "auth":
            guard let token = queryDict["access_token"] else { return }
            let id = queryDict["id"]
            let username = queryDict["username"]
            let fullname = queryDict["fullname"]
            let profilePictureUrl = URL(string: queryDict["profile_picture"] ?? "")
            receivedAuth(token, id, username, fullname, profilePictureUrl)
        default:
            return
        }
    }

    private func getAuthToken() -> String? {
        let query: [CFString: Any] = [
            kSecAttrService: "net.gofake1.drip" as CFString,
            kSecClass: kSecClassGenericPassword,
            kSecMatchLimit: 1,
            kSecReturnData: kCFBooleanTrue
        ]
        var result: AnyObject?
        let copyStatus = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard copyStatus == errSecSuccess,
            let _result = result,
            let data = _result as? Data
            else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Displays the user's profile amd initializes `model`
    /// - postcondition: Saves access token in keychain and user ID in user defaults
    private func receivedAuth(_ token: String, _ id: String?, _ username: String?, _ fullname: String?,
                              _ profilePictureUrl: URL?) {
        if let url = profilePictureUrl {
            let profilePicture = NSImage(byReferencing: url)
            welcomeWC.displayConfirmation(username, fullname, profilePicture)
        } else {
            welcomeWC.displayConfirmation(username, fullname, nil)
        }
        let authStatus = setAuthToken(token, username ?? "Unknown")
        guard authStatus == errSecSuccess else {
            let errStr = SecCopyErrorMessageString(authStatus, nil) as String?
            fatalError(errStr ?? "No error message available.")
        }
        UserDefaults.standard.set(id, forKey: "myId")
        guard let id = id else { fatalError("`id` was nil") }
        model = InstagramModel(token, id)
    }

    /// - postcondition: Sets item in user's keychain
    private func setAuthToken(_ token: String, _ account: String) -> OSStatus {
        let query: [CFString: Any] = [
            kSecAttrAccount: account as CFString,
            kSecAttrService: "net.gofake1.drip" as CFString,
            kSecClass: kSecClassGenericPassword
        ]
        let delStatus = SecItemDelete(query as CFDictionary)
        guard delStatus == errSecSuccess || delStatus == errSecItemNotFound else { return delStatus }
        let attributes: [CFString: Any] = [
            kSecAttrAccount: account as CFString,
            kSecAttrComment: "Drip needs an access token in order to use Instagram's API. If you delete this key, you will need to go through the authorization process again. Do not give access to this token to applications other than Drip." as CFString,
            kSecAttrLabel: "Drip Access Token for Instagram" as CFString,
            kSecAttrService: "net.gofake1.drip" as CFString,
            kSecClass: kSecClassGenericPassword,
            kSecValueData: token.data(using: .utf8)! as CFData
        ]
        return SecItemAdd(attributes as CFDictionary, nil)
    }
}
