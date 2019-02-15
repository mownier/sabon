//
//  SoapParser.swift
//  Networking
//
//  Created by Mounir Ybanez on 8/20/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

public final class SoapParser: NSObject, XMLParserDelegate {
    
    var stack: [String]
    var isBodyFound: Bool
    
    public private(set) var info: [String: Any]
    
    public override init() {
        self.info = [:]
        self.stack = []
        self.isBodyFound = false
        super.init()
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName.lowercased().contains(":body") {
            isBodyFound = true
            return
        }
        
        guard isBodyFound else {
            return
        }
        
        stack.insert(elementName, at: 0)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName.lowercased().contains(":body") {
            isBodyFound = false
        }
        
        guard isBodyFound else {
            return
        }
        
        stack.removeFirst()
        
        guard let value = info[elementName] else {
            return
        }
        
        let key = elementName
        
        if !stack.isEmpty {
            let infoKey = stack.first!
            var infoValue = info[infoKey] as? [String: Any]
            if infoValue == nil {
                infoValue = [String: Any]()
            }
            if let hasKey = infoValue?.contains(where: { $0.key == key }), hasKey {
                let object = infoValue![key]
                var arrayValue: [Any]
                if object is [Any] {
                    arrayValue = object as! [Any]
                    arrayValue.append(value)
                    
                } else {
                    arrayValue = [object!, info[key]!]
                }
                infoValue![key] = arrayValue
                info[infoKey] = infoValue
                
            } else {
                infoValue![key] = value
                info[infoKey] = infoValue
            }
            
            info.removeValue(forKey: key)
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isBodyFound && !stack.isEmpty else {
            return
        }
        
        guard let value = info[stack.first!] as? String else {
            info[stack.first!] = string
            return
        }
        
        info[stack.first!] = value.appending(string)
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        info.removeAll()
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        stack.removeAll()
    }
}
