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
    val[i] = 1
//    if i % 2 == 0 {
//        val[i] = 1
//    } else {
//        val[i] = 0
//    }
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
Math.centralMoments(val)
Math.kurtosis(val)
Math.skewness(val)

func crest(_ value: FloatBuffer) -> Float {
    let energy = Math.energy(value)
    if energy > 0 {
        return Upsurge.max(value) / Upsurge.mean(value)
    } else {
        return 1.0
    }
}

crest(val)

////: [Next](@next)
