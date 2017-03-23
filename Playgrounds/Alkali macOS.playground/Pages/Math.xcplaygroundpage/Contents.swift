//: [Previous](@previous)

import Foundation
import Alkali
import Upsurge

let amps = 120.0
let db = Math.dB(from: amps)

db.toAmps()
amps.toDecibels()

var val = FloatBuffer([0,1,2,3,4,5])

Math.centroid(of: val)
Math.flatness(val)
Math.geometricMean(val)
Math.rootMeanSquare(val)
Math.powerMean(val, power: 2)

//: [Next](@next)
