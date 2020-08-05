//
//  Form.swift
//  ExampleAPI
//
//  Created by Anton Glezman on 19.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

public struct Form {
    public let fields: [FormField]
    
    public init(fields: [FormField]) {
        self.fields = fields
    }
}

public struct FormField {
    public let name: String
    public let data: Data
    public let fileName: String?
    public let mimeType: String?
    
    public init(data: Data, name: String) {
        self.data = data
        self.name = name
        self.fileName = nil
        self.mimeType = nil
    }
    
    public init(data: Data, name: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = nil
        self.mimeType = mimeType
    }
    
    public init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
