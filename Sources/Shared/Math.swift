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
        return Math.innerProduct(x, x)
    }

    public static func energy<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return Math.innerProduct(x, x)
    }

    public static func innerProduct<T: LinearType>(_ x: T, _ y: T) -> Double where T.Element == Double {
        return Upsurge.sum(x * y)
    }

    public static func innerProduct<T: LinearType>(_ x: T, _ y: T) -> Float where T.Element == Float {
        return Upsurge.sum(x * y)
    }

    /// Computes the rolloff of a ```ValueArray```. This is the Nth percentile of the power spectral distribution.
    ///
    public static func rolloff<T: LinearType>(_ value: T, cutoffPercent n: Float = 0.85) -> Float where T.Element == Float {

        guard value.count > 2 else {
            fatalError("Value must have more than two elements!")
        }
        let totalEnergy = Upsurge.sum(value)
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
        let sumOfAmplitudes = Upsurge.sum(value)
        let weights         = FloatBuffer(rampingThrough: 0.0...Float(value.endIndex), by: 1.0)
        let weightedSum     = Upsurge.sum(value * weights)

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

    public static func median(_ x: FloatBuffer) -> Float {
        var temp = x.copy()
        let index = temp.count / 2
        withPointer(&temp) { tPtr in
            vDSP_vsort(tPtr, x.vDSPLength, 1)
        }
        return temp[index]
    }

    public static func mean<T: LinearType>(_ x: T) -> T.Element where T.Element == Float {
        return Upsurge.mean(x)
    }

    public static func geometricMean(_ x: FloatBuffer) -> Float {
        let result = x.copy()
        return exp(Upsurge.sum(Upsurge.log(result)) / Float(x.count))
    }

    public static func rootMeanSquare<T: LinearType>(_ x: T) -> T.Element where T.Element == Float {
        return Upsurge.rmsq(x)
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
            var results = x.copy()
            let powers = FloatBuffer(count: x.count, repeatedValue: power)
            withPointers(&results, powers) { rp, pp in
                vvpowf(rp, pp, rp, [Int32(x.count)])
            }
            return powf(Upsurge.mean(results), 1.0 / power)
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
    
    public static func duration<T: LinearType>(_ x: T, given sampleRate: SampleRate) -> Float where T.Element == Float {
        return  Float(x.count) / sampleRate
    }

    public static func peakEnergy<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return max(abs(x))
    }

    public typealias MomentsTuple = (m0: Float, m1: Float, m2: Float, m3: Float, m4: Float)

    public static func centralMoments(_ value: FloatBuffer) -> MomentsTuple {
        guard value.count >= 2 else {
            fatalError("Cannot compute the central moments for an array of less than two!")
        }

        let valueMean = mean(value)

        var sumTuple:(Float, Float, Float) = (0.0, 0.0, 0.0)
        for i in 0..<value.count {
            let x = value[i] - valueMean
            let x2 = x * x
            sumTuple = (sumTuple.0 + x2, sumTuple.1 + x2 * x, sumTuple.2 + x2 * x2)
        }
        return (
            m0: 1.0,
            m1: 0,
            m2: sumTuple.0 / Float(value.count),
            m3: sumTuple.1 / Float(value.count),
            m4: sumTuple.2 / Float(value.count)
        )

    }

    public static func kurtosis(_ value: FloatBuffer) -> Float {
        let centralMoments = Math.centralMoments(value)
        if centralMoments.m2 == 0 {
            return -3.0
        } else {
            return (centralMoments.m4 / (centralMoments.m2 * centralMoments.m2)) - 3.0
        }
    }

    public static func skewness(_ value: FloatBuffer) -> Float {
        let centralMoments = Math.centralMoments(value)
        if centralMoments.m2 == 0 {
            return 0.0
        } else {
            return (centralMoments.m3 / pow(centralMoments.m2, 1.5))
        }
    }

    public static func spread(_ value: FloatBuffer) -> Float {
        return Math.centralMoments(value).m2
    }

    public static func crest(_ value: FloatBuffer) -> Float {
        let energy = Math.energy(value)
        if energy > 0 {
            return Upsurge.max(value) / Upsurge.mean(value)
        } else {
            return 1.0
        }
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
