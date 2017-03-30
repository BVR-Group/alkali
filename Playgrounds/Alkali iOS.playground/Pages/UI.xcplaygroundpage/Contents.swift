//: [Previous](@previous)

import Foundation
import Alkali
import UIKit
import Accelerate
import AVFoundation
import PlaygroundSupport
import Upsurge

let dimension = 32
let size = CGSize(width: dimension, height: dimension)
let canvas = PixelCanvas(of: size)

func loadFile() {
//    let view: UIImageView

    guard let audioPath = Bundle.main.path(forResource: "DoomTest", ofType: "wav") else {
        return
    }

    let audioFile = URL(fileURLWithPath: audioPath)
    let asset = AVURLAsset(url: audioFile, options: [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true as Bool)])

    guard let assetTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first else {
        return
    }

    guard let reader = try? AVAssetReader(asset: asset) else {
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

    var buffer = Data()

    while reader.status == .reading {
        guard let readSampleBuffer = readerOutput.copyNextSampleBuffer(),
              let readBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                break
        }
        var readBufferLength = 0
        var readBufferPointer: UnsafeMutablePointer<Int8>?
        CMBlockBufferGetDataPointer(readBuffer, 0, &readBufferLength, nil, &readBufferPointer)
        buffer.append(UnsafeBufferPointer(start: readBufferPointer, count: readBufferLength))
        CMSampleBufferInvalidate(readSampleBuffer)
        let samplesToProcess = buffer.count / MemoryLayout<Int16>.size
        if samplesToProcess > 0 {
            drawNumberOfSamples(n: samplesToProcess, to: canvas, from: &buffer)
        }

    }
}

func drawNumberOfSamples(n: Int, to canvas: PixelCanvas, from data: inout Data) {
    data.withUnsafeBytes { (ptr: UnsafePointer<Int16>) in
        var buffer = FloatBuffer(count: n)
        buffer.withUnsafeMutablePointer { bufferPtr in
            let sampleCount = vDSP_Length(n)
            vDSP_vflt16(ptr, 1, bufferPtr, 1, sampleCount)
        }
    }

    data.removeFirst(n * MemoryLayout<Int16>.size)
}

loadFile()


//PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

//audioPlayer?.play()

//
//dump(pixelData.data)

//: [Next](@next)
