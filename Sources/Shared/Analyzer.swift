//
//  Analyzer.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/19/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Upsurge

public final class Analyzer: FFT {
    internal var currentBuffer: FloatBuffer? = nil

    func mirror(_ buffer: FloatBuffer) {
        let half = buffer.count / 2
        buffer[half...buffer.endIndex] = ValueArraySlice<Float>(base: FloatBuffer(buffer[buffer.startIndex..<half].reversed()), startIndex: buffer.startIndex, endIndex: half, step: 1)
    }

    public func process(frames: FloatBuffer) {
        currentBuffer = frames
        super.transform(buffer: frames)

        mirror(complex.real)
        mirror(complex.imaginary)
    }
}

extension Analyzer {
    public func magnitude() -> FloatBuffer {
        var magnitudes = FloatBuffer(zeros: halfN)
        withPointer(&magnitudes) { mPtr in
            vDSP_zvmags(&complex.dspSplitComplex, 1, mPtr, 1, Length(halfN))
        }
        return magnitudes
    }
}
