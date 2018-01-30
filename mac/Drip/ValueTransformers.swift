//
//  ValueTransformers.swift
//  Drip
//
//  Created by David Wu on 9/30/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class InstagramRelationshipOutToStringTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Int else { return nil }
        switch value {
        case InstagramRelationshipOut.follows.bindingValue:   return "Following"
        case InstagramRelationshipOut.none.bindingValue:      return "Follow"
        case InstagramRelationshipOut.requested.bindingValue: return "Requested"
        default: fatalError("Unknown binding value '\(value) for `InstagramRelationshipOut`")
        }
    }
}
