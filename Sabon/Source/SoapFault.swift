//
//  SoapFault.swift
//  Networking
//
//  Created by Mounir Ybanez on 8/20/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

public struct SoapFault {

    public let code: String
    public let string: String
    public let detail: String
    public let actor: String
    
    init(code: String, string: String, detail: String, actor: String) {
        self.code = code
        self.string = string
        self.detail = detail
        self.actor = actor
    }
}

extension Dictionary where Key == String, Value == Any {
    
    var containsSoapFault: Bool {
        return contains(where: { $0.key.lowercased().contains("fault") })
    }
}

extension Dictionary where Key == String, Value == String {
    
    fileprivate func valueOfIgnoredCaseKey(_ key: String) -> Value {
        return self[key.lowercased()] ?? ""
    }
}

public func soapFault(code: String = "", string: String = "", detail: String = "", actor: String = "") -> SoapFault {
    return SoapFault(code: code, string: string, detail: detail, actor: actor)
}

func toSoapFault(from info: [String: Any]) -> SoapFault {
    return info.filter { $0.key.lowercased().contains("fault") }
        .compactMap { $0.value as? [String: String] }
        .map {
            soapFault(
                code: $0.valueOfIgnoredCaseKey("code"),
                string: $0.valueOfIgnoredCaseKey("string"),
                detail: $0.valueOfIgnoredCaseKey("detail"),
                actor: $0.valueOfIgnoredCaseKey("actor")
            )
        }.combinedSoapFault
}

extension Array where Element == SoapFault {
    
    fileprivate var combinedSoapFault: SoapFault {
        return soapFault(
            code: map { $0.code }.joined(separator: "\n"),
            string: map { $0.string }.joined(separator: "\n"),
            detail: map { $0.detail }.joined(separator: "\n"),
            actor: map { $0.actor }.joined(separator: "\n")
        )
    }
}
