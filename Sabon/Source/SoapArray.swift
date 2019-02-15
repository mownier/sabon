//
//  SoapArray.swift
//  Networking
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

public struct SoapArray: SoapObject {

    let itemKey: String
    let items: [SoapObject]
    
    init(itemKey: String, items: [SoapObject]) {
        self.itemKey = itemKey
        self.items = items
    }
    
    public var soapString: String {
        return items.reduce("") { result, object -> String in
            return result.appending("<\(itemKey)>\(object.soapString)</\(itemKey)>")
        }
    }
}

public func soapArray(key: String, items: [SoapObject]) -> SoapArray {
    return SoapArray(itemKey: key, items: items)
}
