//: [Previous](@previous)

import Foundation
import Alkali
import Cocoa
import Accelerate
import AVFoundation
import PlaygroundSupport
import Upsurge

//PlaygroundPage.current.needsIndefiniteExecution = true

func int8toFloat(_ input: UnsafePointer<Int8>, size: Int, channels: Int, channelIndex: Int = 0) -> FloatBuffer {
    let result = FloatBuffer(zeros: size / channels)
    result.withUnsafeMutablePointer { resultPtr in
        if (channels >= 2) {
            vDSP_vflt8(input.advanced(by: channelIndex), vDSP_Stride(channels), resultPtr, 1, vDSP_Length(size / channels))
        } else {
            vDSP_vflt8(input, 1, resultPtr, 1, vDSP_Length(size))
        }
    }

    return result
}

func decimate(_ buffer: FloatBuffer, factor: Int, window: Alkali.Window) -> FloatBuffer {
    var result = FloatBuffer(zeros: buffer.count / factor)
    let windowBuffer: FloatBuffer = window.buffer(Alkali.Window.Length(buffer.count))
    withPointers(buffer, windowBuffer, &result) { bufferPtr, windowPtr, resultPtr in
        vDSP_desamp(bufferPtr, vDSP_Stride(factor), windowPtr, resultPtr, result.vDSPLength, windowBuffer.vDSPLength)
    }
    return result
}

public func drawSpectrogram(of size: CGSize, from url: URL) -> NSImage? {
//    var canvas = PixelCanvas(of: size)
    let sampleBuffer = SampleBuffer(from: url)
    let analyzer = Analyzer(size: 1024, sampleRate: 44100, window: .hamming)

    let results = sampleBuffer.data.withUnsafeBytes { (dataPtr: UnsafePointer<Int8>) -> FloatBuffer in
        return int8toFloat(dataPtr, size: sampleBuffer.data.count, channels: 2, channelIndex: 0)
    }

    results.count
    
    var desampledData = decimate(results, factor: 2, window: .hamming)
    desampledData.count

    let chunkSize = 1024
    var read = 0
    var canvasColumn = 0
//    repeat {
//        let slice = FloatBuffer(ValueArraySlice(base: desampledData, startIndex: read, endIndex: read + chunkSize, step: 1))
//
//        analyzer.process(frames: slice)
//
//        canvasColumn += 1
//        read += chunkSize
//    } while read < sampleBuffer.data.count



//    results.map { $0 }
//    withPointers(results, window, &desampledData) { (resultsPtr, windowPtr, desampPtr) in
//        vDSP_desamp(resultsPtr, Int(analyzer.sampleRate) / 512, windowPtr, desampPtr, results.vDSPLength, window.vDSPLength)
//    }


    return NSImage()
}

let size = CGSize(width: 512, height: 128)
if let audioPath = Bundle.main.path(forResource: "DoomTest", ofType: "wav") {
    let audioURL = URL(fileURLWithPath: audioPath)
    let image = drawSpectrogram(of: size, from: audioURL)
}
//
//
//extension Array {
//    func asPairs() -> [(Iterator.Element, Iterator.Element)] {
//        var result: [(Iterator.Element, Iterator.Element)] = []
//        for (i, value) in self.enumerated() {
//            if i < count - 1 {
//                result.append((value, self[i + 1]))
//            }
//        }
//        return result
//    }
//
//}
//
//func rampARGB(pair: (UIColor, UIColor), steps: Int) -> [UIColor] {
//    return pair.0.ramp(through: pair.1, with: steps, using: UIColor.interpolateARGB)
//}
//
//func rampHSBA(pair: (UIColor, UIColor), steps: Int) -> [UIColor] {
//    return pair.0.ramp(through: pair.1, with: steps, using: UIColor.interpolateHSBA)
//}
//
//
//func spectrum(from colors: [UIColor], steps: Int) -> [UIColor] {
//    var result = [UIColor]()
//
//    let pairs = colors.asPairs()
//
//    for (index, pair) in pairs.enumerated() {
//        var subRamp = pair.0.ramp(through: pair.1, with: steps, using: UIColor.interpolateHSBA)
//
//        if index != pairs.endIndex - 1 {
//            subRamp = Array(subRamp.dropLast(1))
//        }
//        result.append(contentsOf: subRamp)
//    }
//    return result
//}
//
//extension UIColor {
//    class var pistachio: UIColor {
//        return UIColor(red: 134.0/255.0, green: 203.0/255.0, blue: 146.0/255.0, alpha: 1.0)
//    }
//}

//let steps = 8
//let colors:[UIColor] = [.blue, .red, .orange, .black, .pistachio]
//var canvas = PixelCanvas(of: CGSize(width: steps * colors.count, height: 1))
//canvas.size
//
//for (index, color) in spectrum(from: colors , steps: steps).enumerated() {
//    canvas[index, 0] = color
//}
//
//canvas.image?.resized(to: CGSize(width: canvas.size.width * 32, height: canvas.size.height * 64))


//audioPlayer?.play()

//
//dump(pixelData.data)

//: [Next](@next)
