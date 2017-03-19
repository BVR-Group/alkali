//
//  FFT.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/11/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Upsurge

public class FFT {

    public final class Complex {
        public var real: FloatBuffer
        public var imaginary: FloatBuffer

        public var dspSplitComplex: DSPSplitComplex

        public init(_ size: Int = 0) {
            real      = FloatBuffer(zeros: size / 2)
            imaginary = FloatBuffer(zeros: size / 2)
            dspSplitComplex = withPointers(&real, &imaginary) { (realPtr, imagPtr) -> DSPSplitComplex in
                return DSPSplitComplex(realp: realPtr, imagp: imagPtr)
            }
        }
    }

    public typealias Length = vDSP_Length

    internal var n: Int          = 0
    internal var halfN: Int      = 0
    internal var log2N: Float    = 0
    public var sampleRate: Float    = 0
    
    public var nyquist: Float {
        return sampleRate / 2.0
    }

    public var complex = FFT.Complex()

    public var real: FloatBuffer {
        return complex.real
    }

    public var imaginary: FloatBuffer {
        return complex.imaginary
    }

    fileprivate var setup: FFTSetup? = nil

    public init(size: Int, sampleRate: Float) {
        resize(to: size, and: sampleRate)
    }

    fileprivate func upperPOT(_ value: Int) -> Int {
        var v = value
        v -= 1
        v |= v >> 1
        v |= v >> 2
        v |= v >> 4
        v |= v >> 8
        v |= v >> 16
        v += 1
        return v
    }

    public func resize(to length: Int, and sampleRate: Float) {
        if let prexistingSetup = setup {
            vDSP_destroy_fftsetup(prexistingSetup)
        }

        self.n      = upperPOT(length)
        self.log2N  = roundf(log2f(Float(n)))
        self.halfN  = n / 2
        self.sampleRate = sampleRate

        complex = FFT.Complex(halfN)

        guard let fftSetup = vDSP_create_fftsetup(Length(log2N), 0) else {
            fatalError("Failed to init FFT!")
        }
        setup = fftSetup
    }

    internal func transform(buffer: FloatBuffer) {
        guard let fftSetup = setup else {
            fatalError("FFT not setup!")
        }

        buffer.pointer.withMemoryRebound(to: DSPComplex.self, capacity: 1) { ptr in
            vDSP_ctoz(ptr, 2, &complex.dspSplitComplex, 1, Length(halfN))
            vDSP_fft_zrip(fftSetup, &complex.dspSplitComplex, 1, Length(log2N), FFTDirection(FFT_FORWARD))
        }

        complex.real /= 2.0
        complex.imaginary /= 2.0

// TODO: Not sure if this should be here.
//
//        withPointer(&magnitudes) { mPtr in
//            vDSP_zvmags(&complex.dspSplitComplex, 1, mPtr, 1, Length(halfN))
//        }

//        guard let winBuff: FloatBuffer = self.window?.buffer(Length(self.n)) else {
//            return
//        }
//        
//        real      *= winBuff
//        imaginary *= winBuff
    }
}
