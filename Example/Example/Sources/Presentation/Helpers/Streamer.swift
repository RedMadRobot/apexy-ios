//
//  StreamExample.swift
//  Example
//
//  Created by Anton Glezman on 17.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// This class contains an implementation of slow writing data to a stream.
/// It is used only for example of tracking network upload progress.
final class Streamer: NSObject, StreamDelegate {

    struct Streams {
        let input: InputStream
        let output: OutputStream
    }
    
    lazy var boundStreams: Streams = {
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: chunkSize,
                               inputStream: &inputOrNil,
                               outputStream: &outputOrNil)
        guard let input = inputOrNil, let output = outputOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        output.schedule(in: .current, forMode: .default)
        output.open()
        return Streams(input: input, output: output)
    }()
    
    let totalDataSize = 4096
    let chunkSize = 128
    let chunksCount = 32
    private var timer: Timer?
    private var counter: Int = 0
    
    func run() {
        counter = 0
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true)
    }
    
    @objc private func timerFired() {
        if counter == chunksCount {
            boundStreams.output.close()
            timer?.invalidate()
            timer = nil
        } else {
            let data = Data(count: chunkSize)
            _ = data.withUnsafeBytes {
                boundStreams.output.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
            }
            counter += 1
        }
    }
    
    deinit {
        boundStreams.output.close()
        boundStreams.input.close()
        timer?.invalidate()
    }
}
