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

    public func process(frames: FloatBuffer) {
        currentBuffer = frames
        super.transform(buffer: frames)
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
