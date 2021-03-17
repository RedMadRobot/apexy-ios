//
//  RepositoriesLoader.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import Foundation
import ApexyLoader

protocol OrganisationLoading: ContentLoading {
    var state: LoadingState<Organisation> { get }
}

final class OrganisationLoader: WebLoader<Organisation>, OrganisationLoading {
    func load() {
        guard startLoading() else { return }
        request(OrganisationEndpoint()) { result in
            // imitation of waiting for the request for 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.finishLoading(result)
            }
        }
    }
}
