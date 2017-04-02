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
//var canvas = PixelCanvas(of: size)

struct SampleBuffer {
    var data = Data()

    var samplesToProcess: Int {
        return data.count / MemoryLayout<Int16>.size
    }

    var duration: Float {
        return (Float(samplesToProcess) / 44100.0) / 2.0
    }

    init(from url: URL) {
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

func drawSpectrogram(of size: CGSize, from url: URL) {
    let canvas = PixelCanvas(of: size)
//    let sampleBuffer = SampleBuffer(from: url)
//    sampleBuffer.samplesToProcess
//    sampleBuffer.duration
    PlaygroundPage.current.liveView = UIImageView(image: canvas.image)
}

if let audioPath = Bundle.main.path(forResource: "DoomTest", ofType: "wav") {
//    let audioURL = URL(fileURLWithPath: audioPath)
//    drawSpectrogram(of: size, from: audioURL)
}


extension UIColor {
    public var hue: CGFloat {
        var result: CGFloat = 0.0
        self.getHue(&result, saturation: nil, brightness: nil, alpha: nil)
        return result
    }
    public var saturation: CGFloat {
        var result: CGFloat = 0.0
        self.getHue(nil, saturation: &result, brightness: nil, alpha: nil)
        return result
    }
    public var brightness: CGFloat {
        var result: CGFloat = 0.0
        self.getHue(nil, saturation: nil, brightness: &result, alpha: nil)
        return result
    }

    typealias ARGBTuple = (a: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat)

    var colorValues: ARGBTuple {
        var result: ARGBTuple = (a: 0, r: 0, g: 0, b: 0)
        self.getRed(&result.r, green: &result.g, blue: &result.b, alpha: &result.a)
        return result
    }

    convenience init(from tuple: ARGBTuple) {
        self.init(red: tuple.r, green: tuple.g, blue: tuple.b, alpha: tuple.a)
    }

}

func ramp(forRange range: ClosedRange<Float>, by increment: Float) -> FloatBuffer {
    let n = Int(((range.upperBound - range.lowerBound) / increment))
    let result = ValueArray<Float>(zeros: n)
    var increase = increment
    var from = range.lowerBound

    result.withUnsafeMutablePointer { (pointer) -> Void in
        vDSP_vramp(&from, &increase, pointer, 1, result.vDSPLength)
    }
    return result
}

func lerp(from a: CGFloat, to b: CGFloat, time: CGFloat) -> CGFloat {
    return (b - a) * time + a
}

func lerp(from a: UIColor, to b: UIColor, time: CGFloat) -> UIColor {
    var tempA = a.colorValues
    var tempB = b.colorValues
    var result = UIColor.ARGBTuple(a: 0, r: 0, g: 0, b: 0)
    result.a = lerp(from: tempA.a, to: tempB.a, time: time)
    result.r = lerp(from: tempA.r, to: tempB.r, time: time)
    result.g = lerp(from: tempA.g, to: tempB.g, time: time)
    result.b = lerp(from: tempA.b, to: tempB.b, time: time)
    return UIColor(from: result)
}


let steps = 8
let stepSize = 1.0 / Double(steps)
var canvas = PixelCanvas(of: CGSize(width: steps, height: 1))
for i in stride(from: 0.0, through: 1.0, by: stepSize) {
    let index = Int((Double(i) * Double(steps - 1)))
    canvas[index, 0] = lerp(from: .red, to: .purple, time: CGFloat(i))
}

UIImageView(image: canvas.image?.resized(to: CGSize(width: 704, height: 64)))

//PlaygroundPage.current.needsIndefiniteExecution = true


//audioPlayer?.play()

//
//dump(pixelData.data)

//: [Next](@next)
