//
//  Book.swift
//
//  Created by Anton Glezman on 17/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation

/// Response model.
public struct Book: Decodable, Identifiable {
    
    public let id: Int
    public let title: String
    public let authors: String
    public let isbn: String?
    
}
