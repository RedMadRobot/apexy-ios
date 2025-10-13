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

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class RepositoriesLoader: WebLoader<[Repository]>, RepoLoading {
    func load() {
        guard startLoading() else { return }
        Task {
            await request(RepositoriesEndpoint())
        }
    }
}
