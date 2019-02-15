//
//  SoapObject.swift
//  Networking
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

public protocol SoapObject {

    var soapString: String { get }
}

public struct SoapString: SoapObject {
    
    let primitive: SoapPrimitive<String>
    
    public init(key: String = "", value: String) {
        self.primitive = SoapPrimitive(key: key, value: value)
    }
    
    public var soapString: String {
        return primitive.soapString
    }
}

public struct SoapInt: SoapObject {
    
    let primitive: SoapPrimitive<Int64>
    
    public init(key: String = "", value: Int64) {
        self.primitive = SoapPrimitive(key: key, value: value)
    }
    
    public var soapString: String {
        return primitive.soapString
    }
}

public struct SoapDouble: SoapObject {
    
    let primitive: SoapPrimitive<Double>
    
    public init(key: String = "", value: Double) {
        self.primitive = SoapPrimitive(key: key, value: value)
    }
    
    public var soapString: String {
        return primitive.soapString
    }
}

public struct SoapBool: SoapObject {
    
    let primitive: SoapPrimitive<Bool>
    
    public init(key: String = "", value: Bool) {
        self.primitive = SoapPrimitive(key: key, value: value)
    }
    
    public var soapString: String {
        return primitive.soapString
    }
}

public struct SoapPrimitive<V>: SoapObject {
    
    let key: String
    let value: V
    
    public init(key: String = "", value: V) {
        self.key = key
        self.value = value
    }
    
    public var soapString: String {
        guard !key.isEmpty else {
            return String(describing: value)
        }
        return "<\(key)>\(value)</\(key)>"
    }
}

extension String {
    
    public mutating func appendSoapString(_ soapString: SoapString) {
        guard !soapString.primitive.value.isEmpty else {
            return
        }
        append(soapString.soapString)
    }
    
    public mutating func appendSoapInt(_ soapInt: SoapInt, exceptIfValueEqualTo value: Int64? = nil) {
        guard value == nil || soapInt.primitive.value != value! else {
            return
        }
        
        append(soapInt.soapString)
    }
    
    public mutating func appendSoapObject(_ soapObject: SoapObject) {
        append(soapObject.soapString)
    }
    
    public mutating func appendSoapArray(_ soapArray: SoapArray, key: String) {
        guard !soapArray.items.isEmpty else {
            return
        }
        
        guard !key.isEmpty else {
            append(soapArray.soapString)
            return
        }
        
        append("<\(key)>")
        append(soapArray.soapString)
        append("</\(key)>")
    }
}
