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

    var n: Int     = 0
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

    func resize(to length: Int) {
        if let prexistingSetup = setup {
            vDSP_destroy_fftsetup(prexistingSetup)
        }
        self.n = length
        self.halfN = self.n / 2
        self.log2N = round(log2f(Float(n)))

        guard let fftSetup = vDSP_create_fftsetup(Length(log2N), FFTRadix(kFFTRadix2)) else {
            fatalError("Failed to init FFT!")
        }
        setup = fftSetup
    }

    func transform(buffer: FloatBuffer) -> ([Float], [Float]) {
        guard let fftSetup = setup else {
            fatalError("FFT not setup!")
        }
        var real = buffer.copy()
        var imaginary = FloatBuffer(zeros: buffer.count)
//        let magnitudes = FloatBuffer(zeros: buffer.count)
//        let nMag = FloatBuffer(zeros: buffer.count)
        let log2n = Length(roundf(log2f(Float(buffer.count))))

        let bufferSizePOT = Int(1 << log2n)
        var realp = [Float](repeating: 0, count: bufferSizePOT/2)
        var imagp = [Float](repeating: 0, count: bufferSizePOT/2)
        realp.count
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        let s = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        buffer.pointer.withMemoryRebound(to: DSPComplex.self, capacity: 1) { ptr in
            vDSP_ctoz(ptr, 2, &output, 1, Length(bufferSizePOT / 2))
            vDSP_fft_zrip(s!, &output, 1, Length(log2n), FFTDirection(FFT_FORWARD))
        }
//        vDSP_ctoz(UnsafePointer<DSPComplex>(buffer.pointer), 2, &output, 1, UInt(bufferSizePOT/2))
//        withPointers(&real, &imaginary) { (realp, imagp) in
//            var complex = DSPSplitComplex(realp: realp, imagp: imagp)
//
//            complex.realp.withMemoryRebound(to: DSPComplex.self, capacity: 1) {
//                ptr in
//                vDSP_ctoz(ptr, 1, &complex, 1, Length(halfN))
//            }
//
//            vDSP_fft_zrip(fftSetup, &complex, 1, Length(log2N), FFTDirection(FFT_FORWARD))
//
//            real /= 2
//            imaginary /= 2
//
//            guard let winBuff: FloatBuffer = self.window?.buffer(Length(self.n)) else {
//                return
//            }
//
//            real *= winBuff
//            imaginary *= winBuff
//        }
        return (realp, imagp)
    }
}

var bufferS: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)

//bufferS[1] = 1

for i in 0..<bufferS.count {
    let phi = Float(500 / 44100.0)
    bufferS[i] = sin(2.0 * Float(i) * phi * Float.pi)
}

//for i in 0..<bufferS.count {
//    if i % 2 == 1 {
//        bufferS[i] = -1.0
//    }
//}

bufferS.map { $0 }


let fft = FFT(size: bufferS.count)
let result = fft.transform(buffer: bufferS)

result.0.map { $0 }

result.1.map { $0 }



//: [Next](@next)
