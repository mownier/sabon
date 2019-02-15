//
//  SoapEnvelope.swift
//  Networking
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

public final class SoapEnvelope: CustomStringConvertible {
    
    let action: String
    let namespace: String
    
    var parameters: [String: SoapObject]
    
    init(action: String, namespace: String) {
        self.action = action
        self.namespace = namespace
        self.parameters = [:]
    }
    
    public func withParameter(key: String, value: SoapObject) -> SoapEnvelope {
        parameters[key] = value
        return self
    }
    
    public func withParameter<T>(key: String, value: T) -> SoapEnvelope {
        return withParameter(key: key, value: SoapPrimitive<T>(value: value))
    }
    
    public var description: String {
        let body = parameters.reduce("") { result, element -> String in
            return result.appending("<\(element.key)>\(element.value.soapString)</\(element.key)>")
        }
        var string = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        string.append(String(format: "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns=\"\(namespace)\">"))
        string.append("<soap:Body>")
        string.append("<\(action)>\(body.replacingOccurrences(of: "&", with: "&amp;"))</\(action)>")
        string.append("</soap:Body>")
        string.append("</soap:Envelope>")
        return string
    }
}

public func soapEnvelope(action: String, namespace: String) -> SoapEnvelope {
    return SoapEnvelope(action: action, namespace: namespace)
}
