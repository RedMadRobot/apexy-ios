//
//  ViewController.swift
//  Example
//
//  Created by Anton Glezman on 18/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var urlLabel: UILabel!
    @IBOutlet private weak var argsLabel: UILabel!
    @IBOutlet private weak var headersLabel: UILabel!
    
    private let sampleService: SampleService = ServiceLayer.shared.sampleService

    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlLabel.text = nil
        argsLabel.text = nil
        headersLabel.text = nil
    }

    @IBAction private func performRequest() {
        activityIndicator.startAnimating()
        sampleService.obtainData(query: "test") { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            _ = result.map{ self.fillForm(model: $0) }
        }
    }
    
    @IBAction private func upload() {
        activityIndicator.startAnimating()
        sampleService.uploadData() { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            switch result {
            case .success:
                self.urlLabel.text = "ok"
            case .failure(let error):
                self.urlLabel.text = error.localizedDescription
            }
        }
    }
    
    private func fillForm(model: GetResponse) {
        urlLabel.text = model.url
        argsLabel.text = "\(model.args)"
        headersLabel.text = "\(model.headers)"
    }
}

