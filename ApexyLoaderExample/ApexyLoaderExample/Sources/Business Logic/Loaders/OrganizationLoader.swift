//
//  OrganizationLoader.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import Foundation
import ApexyLoader

protocol OrganizationLoading: ContentLoading {
    var state: LoadingState<Organization> { get }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class OrganizationLoader: WebLoader<Organization>, OrganizationLoading {
    func load() {
        guard startLoading() else { return }
        Task {
            await request(OrganizationEndpoint())
        }
    }
}
