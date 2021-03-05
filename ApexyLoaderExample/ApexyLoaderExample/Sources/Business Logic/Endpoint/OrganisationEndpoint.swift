//
//  OrganisationEndpoint.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import Apexy
import Foundation

struct OrganisationEndpoint: BaseEndpoint {
    
    typealias Content = Organisation

    func makeRequest() -> URLRequest {
        let url = URL(string: "orgs/RedMadRobot")!
        return URLRequest(url: url)
    }
    
}
