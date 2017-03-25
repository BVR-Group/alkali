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
    if i % 10 == 0 {
        val[i] = 1
    } else {
        val[i] = 0
    }
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
let centralMoments = Math.centralMoments(val)

// Kurtosis
(centralMoments.m4 / (centralMoments.m2 * centralMoments.m2)) - 3.0

// Skewness
(centralMoments.m3 / pow(centralMoments.m2, 1.5))

////: [Next](@next)
