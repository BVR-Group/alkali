//: [Previous](@previous)

//: Playground - noun: a place where people can play
import Alkali
import Atoll

let size = 512

var bufferS = FloatList(count: size)
var bufferT = FloatList(count: size)
var bufferU = FloatList(count: size)
var bufferV = FloatList(count: size)
//
////bufferS[1] = 1
//func fftToHz(fIndex: Int, size: Int, nyquist: Float) -> Float {
//    let i = Float(fIndex)
//    let s = Float(size)
//    return (i / s) * nyquist
//}
//
// Sin waves
for i in 0..<bufferS.count {
    let phi = Float(Float(size) / 44100.0)
    bufferS[i] = sinf(Float(i) * phi * Float.pi)
}
for i in 0..<bufferT.count {
    let phi = Float(2000 / 44100.0)
    bufferT[i] = sinf(Float(i) * phi * Float.pi)
}
for i in 0..<bufferU.count {
    let phi = Float(4000 / 44100.0)
    bufferU[i] = sinf(Float(i) * phi * Float.pi)
}
//
////Rect
for i in 0..<bufferV.count {
    let phi = Float(0 / 44100.0)
    bufferV[i] = sinf(Float(i) * phi * Float.pi) > 0 ? -1 : 1
}

bufferV.map { $0 } // Inspect me to see the signal!
bufferU.map { $0 }
bufferT.map { $0 }
bufferS.map { $0 }

let combined = (bufferT + bufferS + bufferU + bufferV)
combined.map { $0 } //Inspect me to the see the signal!

//let val = FloatBuffer(rampingThrough: 1...512.0, by: 1.0)
//let val = FloatList(with: 0...512, by: 1)
let analyzer = Analyzer(size: bufferS.count, sampleRate: 44100.0)

analyzer.process(frames: combined)

analyzer.real.startIndex
analyzer.real.halfIndex
analyzer.real.endIndex

analyzer.real.map { $0 }

analyzer.imaginary.map { $0 }

analyzer.magnitudeSpectrum.map { $0 }

analyzer.nyquist

analyzer.zeroCrossingRate()

analyzer.rootMeanSquare()

analyzer.flatness()

analyzer.centroid()

analyzer.rolloff()

//: [Next](@next)
