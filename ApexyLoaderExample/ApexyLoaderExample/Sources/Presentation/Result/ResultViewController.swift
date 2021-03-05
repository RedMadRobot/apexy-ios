//
//  ResultViewController.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import ApexyLoader
import UIKit

final class ResultViewController: UIViewController {

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var repoTextView: UITextView!
    
    private let fileLoader: RepoLoading
    private var observer: LoaderObservation?
    
    init(fileLoader: RepoLoading = ServiceLayer.shared.repoLoader) {
        self.fileLoader = fileLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observer = fileLoader.observe { [weak self] in
            self?.stateDidUpdate()
        }
        stateDidUpdate()
    }
    
    private func stateDidUpdate() {
        if fileLoader.state.isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
        
        switch fileLoader.state {
        case .failure(_, let content?),
             .loading(let content?),
             .success(let content):
            let repos = content.map { $0.name }.joined(separator: "\n")
            repoTextView.text = "Repositories:\n\n\(repos)"
        default:
            break
        }
    }
    
}
