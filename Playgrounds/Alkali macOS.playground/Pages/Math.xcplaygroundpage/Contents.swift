//: [Previous](@previous)

import Foundation
import Alkali
import Upsurge

let amps = 120.0
let db = Math.dB(from: amps)

db.toAmps()
amps.toDecibels()

var val = FloatBuffer(rampingThrough: 0...512.0, by: 1.0)

for i in 0..<val.count {
    val[i] = Float(i)
}
sum(val)

//
//
//Math.centroid(of: val)
//Math.flatness(val)
//Math.geometricMean(val)
//Math.rootMeanSquare(val)
//Math.powerMean(val, power: 2)
//
//sum(val)
//
//
////: [Next](@next)
