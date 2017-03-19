//: [Previous](@previous)

import Foundation
import Alkali
import Upsurge

var vec1 = FloatBuffer(rampingThrough: 0...3.0, by: 0.1)
var vec2 = FloatBuffer(rampingThrough: 0...9.0, by: 0.2)
var result = vec1 * vec2

func innerProduct<T: LinearType>(_ x: T, _ y: T) -> Float where T.Element == Float {
    return sum(x * y)
}

func energy<T: LinearType>(_ x: T) -> Float where T.Element == Float {
    return innerProduct(x, x)
}


innerProduct(vec1, vec2)
energy(vec1)

//: [Next](@next)
