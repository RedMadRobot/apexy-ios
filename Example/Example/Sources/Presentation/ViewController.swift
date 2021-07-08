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
        
        guard #available(macOS 12, iOS 15, *) else { performLegacyRequest(); return }
        
        task = async {
            do {
                let books = try await self.bookService.fetchBooks()
                self.show(books: books)
            } catch {
                self.show(error: error)
            }
        }
    }
    
    private func performLegacyRequest() {
        progress = bookService.fetchBooks() { [weak self] result in
            guard let self = self else { return }
            self.activityView.isHidden = true
            switch result {
            case .success(let books):
                self.show(books: books)
            case .failure(let error):
                self.show(error: error)
            }
        }
    }
    
    
    @IBAction private func upload() {
        guard let file = Bundle.main.url(forResource: "Info", withExtension: "plist") else { return }
        activityView.isHidden = false
     
        guard #available(macOS 12, iOS 15, *) else { legacyUpload(with: file); return }
        
        task = async {
            do {
                try await self.fileService.upload(file: file)
                self.showOKUpload()
            } catch {
                self.show(error: error)
            }
        }
    }
    
    private func legacyUpload(with file: URL) {
        progress = fileService.upload(file: file) { [weak self] result in
            guard let self = self else { return }
            self.activityView.isHidden = true
            switch result {
            case .success:
                self.showOKUpload()
            case .failure(let error):
                self.show(error: error)
            }
        }
    }
    
    @IBAction private func uploadStream() {
        let streamer = Streamer()
        self.streamer = streamer
        activityView.isHidden = false
        
        guard #available(macOS 12, iOS 15, *) else { legacyUploadStream(with: streamer); return }
        
        streamer.run()
        
        task = async {
            do {
                try await self.fileService.upload(stream: streamer.boundStreams.input, size: streamer.totalDataSize)
            } catch {
                self.show(error: error)
                self.streamer?.stop()
            }
        }
    }
    
    private func legacyUploadStream(with streamer: Streamer) {
        progress = fileService.upload(
            stream: streamer.boundStreams.input,
            size: streamer.totalDataSize) { [weak self] result in
                guard let self = self else { return }
                self.activityView.isHidden = true
                switch result {
                case .success:
                    self.showOKUpload()
                case .failure(let error):
                    self.show(error: error)
                    self.streamer = nil
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
        if #available(iOS 15.0, *) {
            (task as? Task.Handle<Void, Never>)?.cancel()
        } else {
            progress?.cancel()
        }
    }
    
    private func show(books: [Book]) {
        resultLabel.text = books.map { "• \($0.title)" }.joined(separator: "\n")
        activityView.isHidden = true
    }
    
    private func show(error: Error) {
        resultLabel.text = error.localizedDescription
        activityView.isHidden = true
    }
    
    private func showOKUpload() {
        resultLabel.text = "ok"
        activityView.isHidden = true
    }
    
}

