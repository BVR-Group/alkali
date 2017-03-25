//
//  Math.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/19/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Upsurge

public enum Math {
    public static let silenceCutoff = 1e-9
    public static let silenceCutoffdB = -90
    public static let log10over20: Double = log(10.0)/20.0
    public static let log10over20f: Float = logf(10.0)/20.0

    public static func isPOT(_ value: Int) -> Bool {
        return (value == 1 || (value & (value - 1)) == 0)
    }

    public static func energy<T: LinearType>(_ x: T) -> Double where T.Element == Double {
        return innerProduct(x, x)
    }

    public static func energy<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return innerProduct(x, x)
    }

    public static func innerProduct<T: LinearType>(_ x: T, _ y: T) -> Double where T.Element == Double {
        return sum(x * y)
    }

    public static func innerProduct<T: LinearType>(_ x: T, _ y: T) -> Float where T.Element == Float {
        return sum(x * y)
    }

    /// Computes the rolloff of a ```ValueArray```. This is the Nth percentile of the power spectral distribution.
    ///
    public static func rolloff<T: LinearType>(_ value: T, cutoffPercent n: Float = 0.85) -> Float where T.Element == Float {

        guard value.count > 2 else {
            fatalError("Value must have more than two elements!")
        }
        let totalEnergy = sum(value)
        let threshold = totalEnergy * n

        var rolloffSum: Float = 0
        var index: Int = 0

        for i in 0..<value.count {
            rolloffSum += value[i]
            if rolloffSum > threshold {
                index = i
                break
            }
        }
        return Float(index) / Float(value.count)
    }

    /// Computes the centroid of a ```ValueArray```.
    ///
    public static func centroid(_ value: ValueArray<Float>) -> Float {
        let sumOfAmplitudes = sum(value)
        let weights         = FloatBuffer(rampingThrough: 0.0...Float(value.endIndex), by: 1.0)
        let weightedSum     = sum(value * weights)

        if sumOfAmplitudes > 0.0 {
            return weightedSum / sumOfAmplitudes
        } else {
            return 0.0
        }
    }

    /// Computes the flatness of an array, which is the ratio between the geometric mean and the
    /// arithmetic mean.
    public static func flatness<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        // We add 1 here to avoid getting a zero result. Since this is a relative value,
        // it works just fine...
        return Math.geometricMean(x + 1) / Upsurge.mean(x + 1)
    }

    public static func median<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return sum(x) / Float(x.count)
    }

    public static func median<T: LinearType>(_ x: T) -> Double where T.Element == Double {
        return sum(x) / Double(x.count)
    }

    public static func mean<T: LinearType>(_ x: T) -> T.Element {
        return mean(x)
    }

    public static func geometricMean<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return exp(sum(log(x)) / Float(x.count))
    }

    public static func rootMeanSquare<T: LinearType>(_ x: T) -> T.Element where T.Element == Float {
        return rmsq(x)
    }

    /// Computes the power mean of an array with a given ```Float``` power.
    ///
    /// If power = -1, the Power Mean is equal to the Harmonic Mean, if power = 0, the Power Mean is
    /// equal to the Geometric Mean, if power = 1, the Power Mean is equal to the Arithmetic Mean,
    /// if p = 2, the Power Mean is equal to the Root Mean Square.
    ///
    /// - attention:
    /// Adapted from [Essentia](http://essentia.upf.edu/)
    ///
    public static func powerMean(_ x: FloatBuffer, power: Float) -> Float {
        if power == 0 {
            return Math.geometricMean(x)
        } else {
            var results = x
            let powers = FloatBuffer(count: x.count, repeatedValue: power)
            withPointers(&results, powers) { rp, pp in
                vvpowf(rp, pp, rp, [Int32(x.count)])
            }
            return powf(mean(results), 1.0 / power)
        }
    }

    public static func instantPower<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return energy(x) / Float(x.count)
    }

    public static func amp(from dB: Decibel) -> Amp {
        if dB > -150.0 {
            return exp(dB * log10over20)
        } else {
            return 0
        }
    }

    public static func dB(from amp: Amp) -> Decibel {
        return 20 * log10(amp)
    }
}

extension Amp {
    public func toDecibels() -> Decibel {
        return Math.dB(from: self)
    }
}

extension Decibel {
    public func toAmps() -> Amp {
        return Math.amp(from: self)
    }
}
