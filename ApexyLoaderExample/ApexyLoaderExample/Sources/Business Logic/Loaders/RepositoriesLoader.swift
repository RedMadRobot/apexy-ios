//
//  RepositoriesLoader.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import Foundation
import ApexyLoader

protocol RepoLoading: ContentLoading {
    var state: LoadingState<[Repository]> { get }
}

final class RepositoriesLoader: WebLoader<[Repository]>, RepoLoading {
    func load() {
        guard startLoading() else { return }
        request(RepositoriesEndpoint()) { result in
            // imitation of waiting for the request for 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.finishLoading(result)
            }
        }
    }
}
