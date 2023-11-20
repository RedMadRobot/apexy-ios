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
    
    private var task: Any?
    private var streamer: Streamer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = nil
    }

    @IBAction private func performRequest() {
        activityView.isHidden = false
        
        task = Task {
            do {
                let books = try await bookService.fetchBooks()
                show(books: books)
            } catch {
                show(error: error)
            }
            activityView.isHidden = true
        }
    }
    
    @IBAction private func upload() {
        guard let file = Bundle.main.url(forResource: "Info", withExtension: "plist") else { return }
        activityView.isHidden = false
        
        task = Task {
            do {
                try await fileService.upload(file: file)
                showOKUpload()
            } catch {
                show(error: error)
            }
            activityView.isHidden = true
        }
    }
        
    @IBAction private func uploadStream() {
        let streamer = Streamer()
        self.streamer = streamer
        activityView.isHidden = false
        
        streamer.run()
        
        task = Task {
            do {
                try await fileService.upload(stream: streamer.boundStreams.input, size: streamer.totalDataSize)
            } catch {
                show(error: error)
                self.streamer = nil
            }
        }
    }
    
    @IBAction private func cancel() {
        if #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) {
            (task as? Task<Void, Never>)?.cancel()
        } else {
            progress?.cancel()
        }
    }
    
    private func show(books: [Book]) {
        resultLabel.text = books.map { "• \($0.title)" }.joined(separator: "\n")
    }
    
    private func show(error: Error) {
        resultLabel.text = error.localizedDescription
    }
    
    private func showOKUpload() {
        resultLabel.text = "ok"
    }
    
}

