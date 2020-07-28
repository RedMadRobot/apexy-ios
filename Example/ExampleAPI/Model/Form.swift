//
//  Form.swift
//  Example
//
//  Created by Anton Glezman on 19.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

struct Form {
    let fields: [FormField]
}


struct FormField {
    let name: String
    let data: Data
    let fileName: String?
    let mimeType: String?
    
    init(data: Data, name: String) {
        self.data = data
        self.name = name
        self.fileName = nil
        self.mimeType = nil
    }
    
    init(data: Data, name: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = nil
        self.mimeType = mimeType
    }
    
    init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
