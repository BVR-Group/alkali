//
//  FFT.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/11/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Atoll
import Accelerate

public class FFT {

    public final class Complex {
        public var real: FloatList
        public var imaginary: FloatList

        public var dspSplitComplex: DSPSplitComplex

        public init(_ size: Int = 0) {
            real      = FloatList(count: size)
            imaginary = FloatList(count: size)
            
            // Wrap them in a DSPSplitComplex
            dspSplitComplex = DSPSplitComplex(realp: real.pointer, imagp: imaginary.pointer)
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

    public var real: FloatList {
        return complex.real
    }

    public var imaginary: FloatList {
        return complex.imaginary
    }

    public var magnitudeSpectrum = FloatList()

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

        self.magnitudeSpectrum = FloatList(count: self.halfN + 1)

        complex = FFT.Complex(halfN)

        guard let fftSetup = vDSP_create_fftsetup(Length(log2N), 0) else {
            fatalError("Failed to init FFT!")
        }
        setup = fftSetup
    }

    internal func transform(buffer: FloatList) {
        var tempBuffer = FloatList(count: n)
        let windowBuffer: FloatList = window.buffer(Length(n))
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

        // Square all of the points in the complex...
        vDSP_zvmags(&complex.dspSplitComplex, 1, magnitudeSpectrum.pointer, 1, Length(halfN))
        
        // Normalize magnitudes
        sqrtInPlace(magnitudeSpectrum)
    }
    
    deinit {
        vDSP_destroy_fftsetup(setup)
    }
}
