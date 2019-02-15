//
//  SoapRequest.swift
//  Networking
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

public final class SoapRequest {
    
    var serviceURL: URL
    var headers: [String: String]
    var soapEnvelope: SoapEnvelope?
    var httpMethod: String
    
    init() {
        self.serviceURL = URL(string: "https://")!
        self.httpMethod = "POST"
        self.headers = ["Content-Type": "text/xml; charset=utf-8"]
    }
    
    public func withServiceURL(_ url: URL?) -> SoapRequest {
        guard url != nil else {
            return self
        }
        
        serviceURL = url!
        headers["Host"] = serviceURL.host ?? ""
        return self
    }
    
    public func withActionURL(_ url: URL?) -> SoapRequest {
        guard url != nil else {
            return self
        }
        
        headers["SOAPAction"] = url!.absoluteString
        return self
    }
    
    public func withEnvelope(_ envelope: SoapEnvelope?) -> SoapRequest {
        guard envelope != nil else {
            return self
        }
        headers["Content-Length"] = "\(envelope!.description.data(using: .utf8)?.count ?? 0)"
        soapEnvelope = envelope
        return self
    }
    
    func toURLRequest() -> URLRequest {
        var request = URLRequest(url: serviceURL)
        request.httpMethod = httpMethod
        if soapEnvelope != nil {
            request.httpBody = soapEnvelope!.description.data(using: .utf8, allowLossyConversion: false)
        }
        headers.forEach { element in
            request.addValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}

public var soapRequest: SoapRequest {
    return SoapRequest()
}

public enum SoapRequestResult {
    
    case okay([String: Any])
    case faulty(SoapFault)
    case notOkay(Error)
}

public struct SoapRequestError: Error, CustomStringConvertible {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
    
    public var description: String {
        return message
    }
}

public func send(_ request: SoapRequest, using session: URLSession = .shared, completion: @escaping (SoapRequestResult) -> Void) {
    let urlRequest = request.toURLRequest()
    let task = session.dataTask(with: urlRequest) { data, response, error in
        guard error == nil else {
            completion(.notOkay(error!))
            return
        }
        
        guard response != nil else {
            completion(.notOkay(SoapRequestError("No response")))
            return
        }
        
        guard data != nil else {
            completion(.notOkay(SoapRequestError("No data")))
            return
        }
        
        let soapParser = SoapParser()
        let xmlParser = XMLParser(data: data!)
        xmlParser.delegate = soapParser
        xmlParser.parse()
        
        if soapParser.info.containsSoapFault {
            completion(.faulty(toSoapFault(from: soapParser.info)))
            
        } else {
            completion(.okay(soapParser.info))
        }
        
    }
    task.resume()
}
