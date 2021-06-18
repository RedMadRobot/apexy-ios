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

final class OrganizationLoader: WebLoader<Organization>, OrganizationLoading {
    func load() {
        guard startLoading() else { return }
        request(OrganizationEndpoint()) { result in
            // imitation of waiting for the request for 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.finishLoading(result)
            }
        }
    }
}
