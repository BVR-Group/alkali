//: [Previous](@previous)

//: Playground - noun: a place where people can play

import Foundation
import Accelerate
import Alkali
import Upsurge

class FFTBuffer {
    var real: FloatBuffer
    var imaginary: FloatBuffer

    var complex: DSPSplitComplex

    init(size: Int) {
        let fb = FloatBuffer(zeros: size / 2)
        let fb2 = FloatBuffer(zeros: size / 2)
        real = fb
        imaginary = fb2
        complex = fb.withUnsafeMutablePointer { (realPtr) -> DSPSplitComplex in
            return fb2.withUnsafeMutablePointer({ (imagPtr) -> DSPSplitComplex in
                return DSPSplitComplex(realp: realPtr, imagp: imagPtr)
            })
        }
    }
}

class FFT {
    typealias Length = vDSP_Length

    var n: Int = 0
    var halfN: Int = 0
    var log2N: Float  = 0


    var window: Window?
    var windowBuffer: FloatBuffer?

    private var setup: FFTSetup? = nil

    init(size: Int, with window: Window? = nil) {
        self.window = window
        self.windowBuffer = window?.buffer(Length(size))
        resize(to: size)
    }

    func upperPOT(_ value: Int) -> Int {
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

    func resize(to length: Int) {
        if let prexistingSetup = setup {
            vDSP_destroy_fftsetup(prexistingSetup)
        }

        self.n = upperPOT(length)
        self.log2N = roundf(log2f(Float(n)))
        self.halfN = Int(log2N / 2.0)

        guard let fftSetup = vDSP_create_fftsetup(Length(log2N), FFTRadix(kFFTRadix2)) else {
            fatalError("Failed to init FFT!")
        }
        setup = fftSetup
    }

    func transform(buffer: FloatBuffer) -> (FloatBuffer, FloatBuffer) {
        guard let fftSetup = setup else {
            fatalError("FFT not setup!")
        }

        var real = FloatBuffer(zeros: n / 2)
        var imaginary = FloatBuffer(zeros: n / 2)

        withPointers(&real, &imaginary) { (realp, imagp) in
            var output = DSPSplitComplex(realp: realp, imagp: imagp)
            buffer.pointer.withMemoryRebound(to: DSPComplex.self, capacity: 1) { ptr in
                vDSP_ctoz(ptr, 2, &output, 1, Length(n / 2))
                vDSP_fft_zrip(fftSetup, &output, 1, Length(log2N), FFTDirection(FFT_FORWARD))
            }
        }

        guard let winBuff: FloatBuffer = self.window?.buffer(Length(self.n)) else {
            return (real, imaginary)
        }

        real      *= winBuff
        imaginary *= winBuff

        return (real, imaginary)
    }
}

var bufferS: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)
var bufferT: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)
var bufferU: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)
var bufferV: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)

//bufferS[1] = 1

// Sin waves
for i in 0..<bufferS.count {
    let phi = Float(250 / 44100.0)
    bufferS[i] = sinf(Float(i) * phi * Float.pi)
}
for i in 0..<bufferT.count {
    let phi = Float(750 / 44100.0)
    bufferT[i] = sinf(Float(i) * phi * Float.pi)
}
for i in 0..<bufferU.count {
    let phi = Float(4000 / 44100.0)
    bufferU[i] = sinf(Float(i) * phi * Float.pi)
}

//Rect
for i in 0..<bufferV.count {
    let phi = Float(0 / 44100.0)
    bufferV[i] = sinf(Float(i) * phi * Float.pi) > 0 ? -1 : 1
}
bufferV.map { $0 }

bufferT.map { $0 }


bufferS.map { $0 }

let combined = (bufferT + bufferS + bufferU + bufferV)
combined.map { $0 }


let fft = FFT(size: bufferS.count)
let result = fft.transform(buffer: combined)
result.0.map { $0 }

result.1.map { $0 }



//: [Next](@next)
