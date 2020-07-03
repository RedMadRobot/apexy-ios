//
//  ViewController.swift
//  Example
//
//  Created by Anton Glezman on 18/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var activityView: UIStackView!
    @IBOutlet private weak var resultLabel: UILabel!
    
    private let bookService: BookService = ServiceLayer.shared.bookService
    private let fileService: FileService = ServiceLayer.shared.fileService

    private var observation: NSKeyValueObservation?
    private var progress: Progress?
    private var streamer = Streamer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = nil
    }

    @IBAction private func performRequest() {
        activityView.isHidden = false
        progress = bookService.fetchBooks() { [weak self] result in
            guard let self = self else { return }
            self.activityView.isHidden = true
            switch result {
            case .success(let books):
                self.show(books: books)
            case .failure(let error):
                self.resultLabel.text = error.localizedDescription
            }
        }
    }
    
    @IBAction private func upload() {
        guard let file = Bundle.main.url(forResource: "Info", withExtension: "plist") else { return }
        activityView.isHidden = false
        progress = fileService.upload(file: file) { [weak self] result in
            guard let self = self else { return }
            self.activityView.isHidden = true
            switch result {
            case .success:
                self.resultLabel.text = "ok"
            case .failure(let error):
                self.resultLabel.text = error.localizedDescription
            }
        }
    }
    
    @IBAction private func uploadStream() {
        streamer = Streamer()
        activityView.isHidden = false
        progress = fileService.upload(
            stream: streamer.boundStreams.input,
            size: streamer.totalDataSize) { [weak self] result in
                guard let self = self else { return }
                self.activityView.isHidden = true
                switch result {
                case .success:
                    self.resultLabel.text = "ok"
                case .failure(let error):
                    self.resultLabel.text = error.localizedDescription
                }
            }
        streamer.run()
        
        observation = progress?.observe(\.fractionCompleted, options: [.new]) { [weak self] (progress, value) in
            DispatchQueue.main.async {
                let percent = (value.newValue ?? 0) * 100
                self?.resultLabel.text = "Progress: \(String(format: "%.0f", percent))%"
            }
        }
    }
    
    @IBAction private func cancel() {
        progress?.cancel()
    }
    
    private func show(books: [Book]) {
        resultLabel.text = books.map { "• \($0.title)" }.joined(separator: "\n")
    }
}

