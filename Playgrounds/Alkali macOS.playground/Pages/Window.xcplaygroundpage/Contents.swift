//: Playground - noun: a place where people can play
import Foundation
import Alkali

let size: UInt = 8

Window<Float>.hamming.buffer(of: size)
Window<Double>.hamming.buffer(of: size)

Window<Float>.hanning.buffer(of: size)
Window<Double>.hanning.buffer(of: size)

Window<Float>.blackman.buffer(of: size)
Window<Double>.blackman.buffer(of: size)

public func bartlett(length n: Int) -> [Double] {
    var result = [Double](repeating: 0.0, count: n)
    for i in 0..<n {
        let I = Double(i)
        let N = Double(n)
        result[i] = 1.0 - abs((2.0 * I - N + 1.0) / (N - 1.0))
    }
    return result
}

public func gaussian(length n: Int) -> [Double] {
    var result = [Double](repeating: 0.0, count: n)
    for i in 0..<n {
        let I = Double(i)
        let N = Double(n)
        result[i] = exp(-1.0 * (2.0 * I - N + 1.0) * (2.0 * I - N + 1.0) / ((N - 1.0) * (N - 1.0)));
    }
    return result
}

let b = bartlett(length: 5)
let g = gaussian(length: 5)
