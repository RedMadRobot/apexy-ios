//
//  GetResponse.swift
//
//  Created by Anton Glezman on 17/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation

/// Response model.
public struct GetResponse: Decodable {
    
    public let args: [String: String]
    public let headers: [String: String]
    public let url: String
    
}
