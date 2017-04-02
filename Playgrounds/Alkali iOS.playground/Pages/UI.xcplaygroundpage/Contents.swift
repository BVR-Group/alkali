//: [Previous](@previous)

import Foundation
import Alkali
import UIKit
import Accelerate
import AVFoundation
import PlaygroundSupport
import Upsurge

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
    public typealias ARGBTuple = (a: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat)
    public typealias HSBATuple = (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)

    public var ARGBColorValues: ARGBTuple {
        var result: ARGBTuple = (a: 0, r: 0, g: 0, b: 0)
        guard self.getRed(&result.r, green: &result.g, blue: &result.b, alpha: &result.a) else {
            fatalError("Unable to convert color!")
        }
        print("ARGB -> \(result)")
        return result
    }

    public var HSBAColorValues: HSBATuple {
        var result: HSBATuple = (h: 0, s: 0, b: 0, a: 0)
        guard self.getHue(&result.h, saturation: &result.s, brightness: &result.b, alpha: &result.a) else {
            fatalError("Unable to convert color!")
        }
        print("HSBA -> \(result)")
        return result
    }

    public convenience init(from tuple: ARGBTuple) {
        self.init(red: tuple.r, green: tuple.g, blue: tuple.b, alpha: tuple.a)
    }

    public convenience init(from tuple: HSBATuple) {
        self.init(hue: tuple.h, saturation: tuple.s, brightness: tuple.b, alpha: tuple.a)
    }

    private static func lerp(from a: CGFloat, to b: CGFloat, percent: CGFloat) -> CGFloat {
        return (b - a) * percent + a
    }

    public typealias ColorInterpolationFunction = (UIColor, UIColor, CGFloat) -> UIColor

    public static func interpolateARGB(from a: UIColor, to b: UIColor, percent: CGFloat) -> UIColor {
        let tempA = a.ARGBColorValues
        let tempB = b.ARGBColorValues
        var result: ARGBTuple = (a: 0, r: 0, g: 0, b: 0)
        result.a = UIColor.lerp(from: tempA.a, to: tempB.a, percent: percent)
        result.r = UIColor.lerp(from: tempA.r, to: tempB.r, percent: percent)
        result.g = UIColor.lerp(from: tempA.g, to: tempB.g, percent: percent)
        result.b = UIColor.lerp(from: tempA.b, to: tempB.b, percent: percent)
        return UIColor(from: result)
    }

    public static func interpolateHSBA(from a: UIColor, to b: UIColor, percent: CGFloat) -> UIColor {
        var tempA = a.HSBAColorValues
        var tempB = b.HSBAColorValues
        var result: HSBATuple = (h: 0, s: 0, b: 0, a: 0)
        var delta = tempB.h - tempA.h
        var p = percent

        if tempA.h > tempB.h {
            let temp = tempB
            tempB = tempA
            tempA = temp

            delta = -1 * delta
            p = 1 - percent
        }

        if delta > 0.5 {
            tempA.h = tempA.h + 1.0
            result.h = (tempA.h + p * (tempB.h - tempA.h))
        }

        if delta <= 0.5 {
            result.h = tempA.h + p * delta
        }

        result.s = UIColor.lerp(from: tempA.s, to: tempB.s, percent: p)
        result.b = UIColor.lerp(from: tempA.b, to: tempB.b, percent: p)
        result.a = UIColor.lerp(from: tempA.a, to: tempB.a, percent: p)

        print(result)
        return UIColor(from: result)
    }

    public func interpolate(to color: UIColor, percent: CGFloat, using function: ColorInterpolationFunction) -> UIColor {
        return function(self, color, percent)
    }

    public func ramp(through color: UIColor, withSteps: Int, using function: ColorInterpolationFunction) -> [UIColor] {
        let stepSize = 1.0 / Double(steps)
        var result = [UIColor]()
        for i in stride(from: 0.0, through: 1.0, by: stepSize) {
            result.append(self.interpolate(to: color, percent: CGFloat(i), using: function))
        }
        return result
    }

}

extension Array {
    func asPairs() -> [(Iterator.Element, Iterator.Element)] {
        var result: [(Iterator.Element, Iterator.Element)] = []
        for (i, value) in self.enumerated() {
            if i < count - 1 {
                result.append((value, self[i + 1]))
            }
        }
        return result
    }

}

func rampARGB(pair: (UIColor, UIColor), steps: Int) -> [UIColor] {
    return pair.0.ramp(through: pair.1, withSteps: steps, using: UIColor.interpolateARGB)
}

func rampHSBA(pair: (UIColor, UIColor), steps: Int) -> [UIColor] {
    return pair.0.ramp(through: pair.1, withSteps: steps, using: UIColor.interpolateHSBA)
}


func spectrum(from colors: [UIColor], steps: Int) -> [UIColor] {
    var result = [UIColor]()

    let pairs = colors.asPairs()

    for (index, pair) in pairs.enumerated() {
        var subRamp = pair.0.ramp(through: pair.1, withSteps: steps, using: UIColor.interpolateHSBA)

        if index != pairs.endIndex - 1 {
            subRamp = Array(subRamp.dropLast(1))
        }
        result.append(contentsOf: subRamp)
    }
    return result
}

let steps = 25
let colors:[UIColor] = [.black, .blue, .purple, .red, .yellow]
var canvas = PixelCanvas(of: CGSize(width: steps * colors.count, height: 1))

for (index, color) in spectrum(from: colors , steps: steps).enumerated() {
    canvas[index, 0] = color
}

UIImageView(image: canvas.image?.resized(to: CGSize(width: 704, height: 64)))

//PlaygroundPage.current.needsIndefiniteExecution = true


//audioPlayer?.play()

//
//dump(pixelData.data)

//: [Next](@next)
