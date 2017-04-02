//
//  SampleBuffer.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 4/2/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//
import Foundation
import AVFoundation

public struct SampleBuffer {
    public var data = Data()

    public var samplesToProcess: Int {
        return data.count / MemoryLayout<Int8>.size
    }

    public var duration: Float {
        return (Float(samplesToProcess) / 44100.0) / 2.0
    }

    public init(from url: URL) {
        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true as Bool)])

        guard let assetTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first,
            let reader = try? AVAssetReader(asset: asset) else {
                return
        }

        let outputSettings: [String : Any] = [
            AVFormatIDKey:                  Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey:         16,
            AVLinearPCMIsBigEndianKey:      false,
            AVLinearPCMIsFloatKey:          false,
            AVLinearPCMIsNonInterleaved:    false
        ]

        let readerOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: outputSettings)
        readerOutput.alwaysCopiesSampleData = false
        reader.add(readerOutput)
        reader.startReading()

        while reader.status == .reading {
            guard   let readSampleBuffer = readerOutput.copyNextSampleBuffer(),
                let readBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                    break
            }
            var readBufferLength = 0
            var readBufferPointer: UnsafeMutablePointer<Int8>?

            CMBlockBufferGetDataPointer(readBuffer, 0, &readBufferLength, nil, &readBufferPointer)
            data.append(UnsafeBufferPointer(start: readBufferPointer, count: readBufferLength))
            CMSampleBufferInvalidate(readSampleBuffer)
        }
        
    }
}
