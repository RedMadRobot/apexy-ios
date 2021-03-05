//
//  RepositoriesEndpoint.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import Apexy
import Foundation

/// List of all Redmadrobot repositories on GitHub
struct RepositoriesEndpoint: BaseEndpoint {
    
    typealias Content = [Repository]

    func makeRequest() -> URLRequest {
        let url = URL(string: "orgs/RedMadRobot/repos")!
        return URLRequest(url: url)
    }
    
}
