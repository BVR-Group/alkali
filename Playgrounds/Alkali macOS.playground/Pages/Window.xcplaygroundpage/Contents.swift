//: Playground - noun: a place where people can play
import Foundation
import Alkali

let size: UInt = 21

Window<Float>.hamming.buffer(of: size).map { $0 }
Window<Double>.hamming.buffer(of: size).map { $0 }

Window<Float>.hanning.buffer(of: size).map { $0 }
Window<Double>.hanning.buffer(of: size).map { $0 }

Window<Float>.blackman.buffer(of: size).map { $0 }
Window<Double>.blackman.buffer(of: size).map { $0 }

public func bartlett(length n: Int) -> [Double] {
    return (0..<n).map {
        let I = Double($0)
        let N = Double(n)
        return 1.0 - abs((2.0 * I - N + 1.0) / (N - 1.0))
    }
}

public func gaussian(length n: Int) -> [Double] {
    return (0..<n).map {
        let I = Double($0)
        let N = Double(n)
        return exp(-1.0 * (2.0 * I - N + 1.0) * (2.0 * I - N + 1.0) / ((N - 1.0) * (N - 1.0)))
    }
}

bartlett(length: Int(size)).map { $0 }

gaussian(length: Int(size)).map { $0 }




