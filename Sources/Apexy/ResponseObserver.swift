//
//  ResponseObserver.swift
//  
//
//  Created by Aleksei Tiurnin on 31.08.2022.
//

import Foundation

public typealias ResponseObserver = (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Void
