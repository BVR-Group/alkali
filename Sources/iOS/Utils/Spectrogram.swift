//
//  Spectrogram.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 4/2/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import UIKit
import Accelerate
import Upsurge

public func drawSpectrogram(of size: CGSize, from url: URL) -> UIImage? {
    var canvas = PixelCanvas(of: size)
    let sampleBuffer = SampleBuffer(from: url)
    //    sampleBuffer.samplesToProcess
    //    sampleBuffer.duration
    let results = FloatBuffer(zeros: sampleBuffer.data.count)
    results.withUnsafeMutablePointer { resultsPtr in
        sampleBuffer.data.withUnsafeBytes { (ptr: UnsafePointer<Int8>) in
            vDSP_vflt8(ptr, 1, resultsPtr, 1, results.vDSPLength)
        }
    }

    let analyzer = Analyzer(size: 1024, sampleRate: 44100, window: .hamming)
    let chunkSize = 1024
    var read = 0
    var canvasColumn = 0
    repeat {
        let slice = FloatBuffer(ValueArraySlice(base: results, startIndex: read, endIndex: read + chunkSize, step: 1))
        analyzer.process(frames: slice)
        for value in analyzer.magnitudeSpectrum.enumerated() {
            canvas[canvasColumn, value.offset] = UIColor(red: CGFloat(value.element), green: 0.5, blue: 0.5, alpha: 1.0)
        }
        canvasColumn += 1
        read += chunkSize
    } while read < sampleBuffer.data.count
    return canvas.image
}
