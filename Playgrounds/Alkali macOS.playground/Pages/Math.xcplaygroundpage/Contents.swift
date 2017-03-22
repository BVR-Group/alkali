//: [Previous](@previous)

import Foundation
import Alkali
import Upsurge

let amps = 120.0
let db = Math.dB(from: amps)

db.toAmps()
amps.toDecibels()

var val = FloatBuffer.init(count: 512, repeatedValue: 0.0)

for i in 0..<val.count where i % 2 == 0 {
    val[i] = 2.0
}

val

func flatness(_ value: FloatBuffer) -> Float {
    return gMean(value + 1) / mean(value + 1)
}

func gMean(_ value: FloatBuffer) -> Float {
    return exp(sum(log(value)) / Float(value.count))
}

Math.centroid(of: val)
flatness(val)
gMean(val)

Math.flatness(val)
Math.geometricMean(val)

//: [Next](@next)
