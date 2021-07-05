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
    private var streamer: Streamer?
    private var cancelTask: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = nil
    }

    @IBAction private func performRequest() {
        updateActivityIndicator(isHidden: false)
        
        guard #available(macOS 12, iOS 15, *) else { performLegacyRequest(); return }
        
        let task = detach { [weak self] in
            guard let self = self else { return }
            do {
                let books = try await self.bookService.fetchBooks()
                await self.show(books: books)
            } catch {
                await self.show(error: error)
            }
            await self.updateActivityIndicator(isHidden: true)
        }
        
        cancelTask = {
            task.cancel()
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
        
        let task = detach { [weak self] in
            guard let self = self else { return }
            do {
                try await self.fileService.upload(file: file)
                await self.showOKUpload()
            } catch {
                await self.show(error: error)
            }
            await self.updateActivityIndicator(isHidden: true)
        }
        
        cancelTask = {
            task.cancel()
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
        
        let task = detach { [weak self] in
            guard let self = self else { return }
            do {
                try await self.fileService.upload(stream: streamer.boundStreams.input, size: streamer.totalDataSize)
            } catch {
                await self.show(error: error)
                await self.streamer?.stop()
            }
            await self.updateActivityIndicator(isHidden: true)
        }
        
        cancelTask = {
            task.cancel()
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
        progress?.cancel()
        cancelTask?()
    }
    
    @MainActor
    private func show(books: [Book]) {
        resultLabel.text = books.map { "• \($0.title)" }.joined(separator: "\n")
    }
    
    @MainActor
    private func show(error: Error) {
        resultLabel.text = error.localizedDescription
    }
    
    @MainActor
    private func updateActivityIndicator(isHidden: Bool) {
        activityView.isHidden = isHidden
    }
    
    @MainActor
    private func showOKUpload() {
        resultLabel.text = "ok"
    }
    
}

