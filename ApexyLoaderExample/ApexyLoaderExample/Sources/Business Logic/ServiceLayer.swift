//
//  ServiceLayer.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import Apexy
import ApexyURLSession
import Foundation

final class ServiceLayer {
    static let shared = ServiceLayer()
    private init() {}
    
    private(set) lazy var repoLoader: RepoLoading = RepositoriesLoader(apiClient: apiClient)
    private(set) lazy var orgLoader: OrganizationLoading = OrganizationLoader(apiClient: apiClient)
    
    private lazy var apiClient: Client = {
        URLSessionClient(
            baseURL: URL(string: "https://api.github.com")!,
            configuration: .ephemeral
        )
    }()
}
