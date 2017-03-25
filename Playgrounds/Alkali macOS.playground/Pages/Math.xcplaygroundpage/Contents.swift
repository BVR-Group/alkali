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
val

Math.centroid(val)
Math.flatness(val)
Math.geometricMean(val)
Math.rootMeanSquare(val)

Math.powerMean(val, power: 4)

Math.duration(val, given: 44100)
Math.energy(val)
Math.instantPower(val)

Math.mean(val)
Math.median(val)
Math.rolloff(val)


////: [Next](@next)
