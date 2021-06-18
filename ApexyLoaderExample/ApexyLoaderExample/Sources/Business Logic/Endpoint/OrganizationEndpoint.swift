//
//  OrganizationEndpoint.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import Apexy
import Foundation

struct OrganizationEndpoint: BaseEndpoint {
    
    typealias Content = Organization

    func makeRequest() -> URLRequest {
        let url = URL(string: "orgs/RedMadRobot")!
        return URLRequest(url: url)
    }
    
}
