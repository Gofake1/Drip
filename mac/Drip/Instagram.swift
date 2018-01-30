//
//  Instagram.swift
//  Drip
//
//  Created by David Wu on 9/7/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

enum InstagramRelationshipOut: String {
    case follows
    case none
    case requested

    var bindingValue: Int {
        switch self {
        case .follows:   return 0
        case .none:      return 1
        case .requested: return 2
        }
    }

    init(bindingValue: Int) {
        switch bindingValue {
        case 0: self = .follows
        case 1: self = .none
        case 2: self = .requested
        default: fatalError("Unknown binding value for `InstagramRelationshipOut")
        }
    }
}

struct FollowsJSON: Decodable {
    struct UserDict: Decodable {
        var username: String
        var profile_picture: URL
        var full_name: String
        var id: String
    }

    var data: [UserDict]
}

struct MediaJSON: Decodable {
    struct ItemDict: Decodable {
        struct ImagesDict: Decodable {
            struct ImageDict: Decodable {
                var url: URL
            }

            var standard_resolution: ImageDict
        }

        var id: String
        var images: ImagesDict
        var type: String
    }

    var data: [ItemDict]
}

struct RelationshipJSON: Decodable {
    struct DataDict: Decodable {
        var outgoing_status: String
    }

    var data: DataDict
}

struct UserJSON: Decodable {
    struct DataDict: Decodable {
        struct CountsDict: Decodable {
            var media: Int
            var follows: Int
            var followed_by: Int
        }

        var id: String
        var username: String
        var full_name: String
        var profile_picture: URL
        var counts: CountsDict
    }

    var data: DataDict
}

class FeedViewModel: NSObject {
    @objc dynamic var items = [FeedItemViewModel]()
}

class FeedItemViewModel: NSObject {
    @objc dynamic var image: NSImage
    @objc dynamic var username: String
    let userId: String

    init(_ image: NSImage, _ username: String, _ userId: String) {
        self.image = image
        self.username = username
        self.userId = userId
    }
}

class UserViewModel: NSObject {
    @objc dynamic var images = [NSImage]()
    @objc dynamic var relationship = InstagramRelationshipOut.none.bindingValue
    @objc dynamic var isMyself = false
    @objc dynamic var username = ""
    @objc dynamic var numFollowers = ""
    @objc dynamic var numFollowing = ""
    @objc dynamic var numPosts = ""
    @objc dynamic var profileImage = NSImage(named: .userGuest)!
}

class InstagramTaskBuilder {
    private let accessToken: String
    private let baseUrl = URL(string: "https://api.instagram.com/v1/")!
    private let session = URLSession(configuration: .default)

    init(_ accessToken: String) {
        self.accessToken = accessToken
    }

//    func comment(_ mediaId: String, text: String) -> URLSessionUploadTask {
//        var request = URLRequest(url: URL(string: "media/\(mediaId)/comments?access_token=\(accessToken)", relativeTo: baseUrl)!)
//        request.httpMethod = "POST"
//        return session.uploadTask(with: request, from: <#T##Data#>)
//    }

    func comments(_ mediaId: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
        let url = URL(string: "media/\(mediaId)/comments?access_token=\(accessToken)", relativeTo: baseUrl)!
        return session.dataTask(with: url, completionHandler: completionHandler)
    }

    func followers(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
        let url = URL(string: "users/self/followed_by?access_token=\(accessToken)", relativeTo: baseUrl)!
        return session.dataTask(with: url, completionHandler: completionHandler)
    }

    func following(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
        let url = URL(string: "users/self/follows?access_token=\(accessToken)", relativeTo: baseUrl)!
        return session.dataTask(with: url, completionHandler: completionHandler)
    }

    func relationship(to userId: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
        let url = URL(string: "users/\(userId)/relationship?access_token=\(accessToken)", relativeTo: baseUrl)!
        return session.dataTask(with: url, completionHandler: completionHandler)
    }

    func setRelationship(_ newRelationship: InstagramRelationshipOut, for userId: String)
        -> URLSessionDataTask {
        let action: String
        switch newRelationship {
        case .follows:   action = "follow"
        case .none:      action = "unfollow"
        case .requested: fatalError("Unsupported action")
        }
        var request = URLRequest(url:
            URL(string: "users/\(userId)/relationship?access_token=\(accessToken)&action=\(action)",
                relativeTo: baseUrl)!)
        request.httpMethod = "POST"
        return session.dataTask(with: request)
    }

    func user(_ id: String, _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
        let url = URL(string: "users/\(id)/?access_token=\(accessToken)", relativeTo: baseUrl)!
        return session.dataTask(with: url, completionHandler: completionHandler)
    }

    func userImages(_ userId: String, after mediaId: String? = nil,
                    _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
            let url: URL
        if let minId = mediaId {
            url = URL(string: "users/\(userId)/media/recent?access_token=\(accessToken)&min_id=\(minId)",
                      relativeTo: baseUrl)!
        } else {
            url = URL(string: "users/\(userId)/media/recent?access_token=\(accessToken)",
                      relativeTo: baseUrl)!
        }
        return session.dataTask(with: url, completionHandler: completionHandler)
    }
}

class InstagramModel: NSObject {
    let myId: String
    private var userMediaIds = [String: (earliest: String, latest: String)]()
    private let decoder: JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    private let instagramTask: InstagramTaskBuilder

    init(_ accessToken: String, _ myId: String) {
        instagramTask = InstagramTaskBuilder(accessToken)
        self.myId = myId
    }

    func toggleFollow(_ userId: String, currentRelationship: InstagramRelationshipOut) {
        switch currentRelationship {
        case .follows:
            instagramTask.setRelationship(.none, for: userId).resume()
        case .none:
            instagramTask.setRelationship(.follows, for: userId).resume()
        case .requested:
            instagramTask.setRelationship(.none, for: userId).resume()
        }
    }

    func updateFeed(_ vm: FeedViewModel) {
        instagramTask.following {
            [weak self = self, weak vm = vm] (data, response, error) in
            guard error == nil else { fatalError(error!.localizedDescription) }
            guard let data = data else { return }
            do {
                guard let json = try self?.decoder.decode(FollowsJSON.self, from: data) else { return }
                for user in json.data {
                    self?.instagramTask.userImages(user.id) { (data, response, error) in
                        guard error == nil else { fatalError(error!.localizedDescription) }
                        guard let data = data else { return }
                        do {
                            guard let json = try self?.decoder.decode(MediaJSON.self, from: data),
                                json.data.count > 0
                                else { return }
                            let image = NSImage(byReferencing: json.data[0].images.standard_resolution.url)
                            let feedItemVM = FeedItemViewModel(image, user.username, user.id)
                            DispatchQueue.main.async {
                                vm?.items.insert(feedItemVM, at: 0)
                            }
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }.resume()
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }.resume()
    }

    func updateUser(_ id: String, _ vm: UserViewModel) {
        vm.isMyself = id == myId
        if !vm.isMyself {

        }
        instagramTask.relationship(to: id) {
            [weak self = self, weak vm = vm] (data, response, error) in
            guard error == nil else { fatalError(error!.localizedDescription) }
            guard let data = data else { return }
            do {
                guard let json = try self?.decoder.decode(RelationshipJSON.self, from: data) else { return }
                DispatchQueue.main.async {
                    vm?.relationship =
                        InstagramRelationshipOut(rawValue: json.data.outgoing_status)!.bindingValue
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }.resume()
        instagramTask.user(id) {
            [weak self = self, weak vm = vm] (data, response, error) in
            guard error == nil else { fatalError(error!.localizedDescription) }
            guard let data = data else { return }
            do {
                guard let json = try self?.decoder.decode(UserJSON.self, from: data) else { return }
                let profileImage = NSImage(byReferencing: json.data.profile_picture)
                DispatchQueue.main.async {
                    vm?.username = json.data.username
                    vm?.numFollowers = "\(json.data.counts.followed_by)"
                    vm?.numFollowing = "\(json.data.counts.follows)"
                    vm?.numPosts = "\(json.data.counts.media)"
                    vm?.profileImage = profileImage
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }.resume()
        instagramTask.userImages(id) {
            [weak self = self, weak vm = vm] (data, response, error) in
            guard error == nil else { fatalError(error!.localizedDescription) }
            guard let data = data else { return }
            do {
                guard let json = try self?.decoder.decode(MediaJSON.self, from: data) else { return }
                for item in json.data {
                    let image = NSImage(byReferencing: item.images.standard_resolution.url)
                    DispatchQueue.main.async {
                        vm?.images.append(image)
                    }
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }.resume()
    }
}
