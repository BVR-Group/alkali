//: [Previous](@previous)

//: Playground - noun: a place where people can play

import Foundation
import Accelerate
import Alkali
import Upsurge

var bufferS: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)
var bufferT: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)
var bufferU: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)
var bufferV: FloatBuffer = FloatBuffer(count: 1024, repeatedValue: 0)

//bufferS[1] = 1
func fftToHz(fIndex: Int, size: Int, nyquist: Float) -> Float {
    let i = Float(fIndex)
    let s = Float(size)
    return (i / s) * nyquist
}

// Sin waves
for i in 0..<bufferS.count {
    let phi = Float(250 / 44100.0)
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

//Rect
for i in 0..<bufferV.count {
    let phi = Float(0 / 44100.0)
    bufferV[i] = sinf(Float(i) * phi * Float.pi) > 0 ? -1 : 1
}
bufferV.map { $0 }
bufferU.map { $0 }

bufferT.map { $0 }


bufferS.map { $0 }

let combined = (bufferT + bufferS + bufferU + bufferV)
combined.map { $0 }



let analyzer = Analyzer(size: bufferS.count, sampleRate: 44100.0)

analyzer.process(frames: combined)
analyzer.real.map { $0 }

analyzer.magnitude().map({ $0 })
analyzer.zeroCrossingRate()


//: [Next](@next)
