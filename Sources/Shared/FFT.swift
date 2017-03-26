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
            real      = FloatBuffer(zeros: size)
            imaginary = FloatBuffer(zeros: size)
            dspSplitComplex = withPointers(&real, &imaginary) { (realPtr, imagPtr) -> DSPSplitComplex in
                return DSPSplitComplex(realp: realPtr, imagp: imagPtr)
            }
        }
    }

    public typealias Length = vDSP_Length

    internal var n: Int             = 0
    internal var halfN: Int         = 0
    internal var log2N: Float       = 0
    public   var sampleRate: Float  = 0
    
    public var nyquist: Float {
        return sampleRate / 2.0
    }

    public var window: Window

    public var complex = FFT.Complex()

    public var real: FloatBuffer {
        return complex.real
    }

    public var imaginary: FloatBuffer {
        return complex.imaginary
    }

    public var magnitudeSpectrum = FloatBuffer()

    fileprivate var setup: FFTSetup? = nil

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

    public init(size: Int, sampleRate: Float, window: Window = .hanning) {
        self.window = window
        resize(to: size, and: sampleRate)
    }

    public func resize(to length: Int, and sampleRate: Float) {
        if let prexistingSetup = setup {
            vDSP_destroy_fftsetup(prexistingSetup)
        }

        self.n          = upperPOT(length)
        self.log2N      = log2f(Float(n))
        self.halfN      = n / 2
        self.sampleRate = sampleRate

        self.magnitudeSpectrum = FloatBuffer(zeros: self.halfN)

        complex = FFT.Complex(halfN)

        guard let fftSetup = vDSP_create_fftsetup(Length(log2N), 0) else {
            fatalError("Failed to init FFT!")
        }
        setup = fftSetup
    }

    internal func transform(buffer: FloatBuffer) {
        var tempBuffer = FloatBuffer(zeros: n)
        let windowBuffer: FloatBuffer = window.buffer(Length(n))
        tempBuffer = buffer * windowBuffer

        guard let fftSetup = setup else {
            fatalError("FFT not setup!")
        }

        tempBuffer.pointer.withMemoryRebound(to: DSPComplex.self, capacity: 1) { ptr in
            // Pack the audio buffer into a complex...
            vDSP_ctoz(ptr, 2, &complex.dspSplitComplex, 1, Length(halfN))

            // Run the forward FFT using the prior setup...
            vDSP_fft_zrip(fftSetup, &complex.dspSplitComplex, 1, Length(log2N), FFTDirection(FFT_FORWARD))
        }

        // Prepare the complex to be mirrored and correct wrong(?) values coming from the accelerate FFT...
        complex.real[halfN]      = complex.imaginary[0]
        complex.imaginary[halfN] = 0.0
        complex.imaginary[0]     = 0.0

        // Halve the values to achieve appropriate scale...
        complex.real      *= 0.5
        complex.imaginary *= 0.5

        // Make the complex results symetrical instead of doing it in
        // the various algorithms (questionable decision)...
        complex.real.mirror()
        complex.imaginary.mirror()

        withPointer(&magnitudeSpectrum) { mPtr in
            // Square all of the points in the complex...
            vDSP_zvmags(&complex.dspSplitComplex, 1, mPtr, 1, Length(halfN))
        }
    }
}
