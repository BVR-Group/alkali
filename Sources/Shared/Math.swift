//
//  Math.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/19/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Atoll
import Accelerate

public enum Math {
    public static let silenceCutoff = 1e-9
    public static let silenceCutoffdB = -90
    public static let log10over20: Double = log(10.0)/20.0
    public static let log10over20f: Float = logf(10.0)/20.0

    public static func isPOT(_ value: Int) -> Bool {
        return (value == 1 || (value & (value - 1)) == 0)
    }

    public static func energy(_ x: DoubleList) -> Double {
        return innerProduct(x, x)
    }

    public static func energy(_ x: FloatList) -> Float {
        return innerProduct(x, x)
    }

    /// Computes the rolloff of a ```ValueArray```. This is the Nth percentile of the power spectral distribution.
    ///
    public static func rolloff(_ value: FloatList, cutoffPercent n: Float = 0.85) -> Float {

        guard value.count > 2 else {
            fatalError("Value must have more than two elements!")
        }
        let totalEnergy = Atoll.sum(value)
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

    /// Computes the centroid of a ```FloatList```.
    ///
    public static func centroid(_ value: FloatList) -> Float {
        let sumOfAmplitudes = Atoll.sum(value)
        let weights         = FloatList(with: 0...Float(value.endIndex), by: 1)
        let weightedSum     = sum(value * weights)

        if sumOfAmplitudes > 0.0 {
            return weightedSum / sumOfAmplitudes
        } else {
            return 0.0
        }
    }

    /// Computes the flatness of an array, which is the ratio between the geometric mean and the
    /// arithmetic mean.
    public static func flatness(_ x: FloatList) -> Float {
        // We add 1 here to avoid getting a zero result. Since this is a relative value,
        // it works just fine...
        return geometricMean(x + 1) / mean(x + 1)
    }

    public static func median(_ x: FloatList) -> Float {
        var temp = x.copy()
        let index = temp.count / 2
        vDSP_vsort(temp.pointer, x.vDSP_Length, 1)
        return temp[index]
    }

    public static func geometricMean(_ x: FloatList) -> Float {
        let result = x.copy()
        return exp(log(sum(result)) / Float(x.count))
    }

    /// Computes the power mean of an array with a given ```Float``` power.
    ///
    /// If power = -1, the Power Mean is equal to the Harmonic Mean, if power = 0, the Power Mean is
    /// equal to the Geometric Mean, if power = 1, the Power Mean is equal to the Arithmetic Mean,
    /// if p = 2, the Power Mean is equal to the Root Mean Square.
    ///
    /// - Authors:
    /// Adapted from [Essentia](http://essentia.upf.edu/)
    ///
    public static func powerMean(_ x: FloatList, power: Float) -> Float {
        if power == 0 {
            return geometricMean(x)
        } else {
            let powers = FloatList(repeating: power, count: x.count)
            return powf(mean(pow(x, powers)), 1.0 / power)
        }
    }

    public static func instantPower(_ x: FloatList) -> Float {
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
    
    public static func duration(_ x: FloatList, given sampleRate: SampleRate) -> Float {
        return  Float(x.count) / sampleRate
    }

    public static func peakEnergy(_ x: FloatList) -> Float {
        return max(abs(x))
    }

    public typealias MomentsTuple = (m0: Float, m1: Float, m2: Float, m3: Float, m4: Float)

    public static func centralMoments(_ value: FloatList) -> MomentsTuple {
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

    public static func kurtosis(_ value: FloatList) -> Float {
        let centralMoments = Math.centralMoments(value)
        if centralMoments.m2 == 0 {
            return -3.0
        } else {
            return (centralMoments.m4 / (centralMoments.m2 * centralMoments.m2)) - 3.0
        }
    }

    public static func skewness(_ value: FloatList) -> Float {
        let centralMoments = Math.centralMoments(value)
        if centralMoments.m2 == 0 {
            return 0.0
        } else {
            return (centralMoments.m3 / pow(centralMoments.m2, 1.5))
        }
    }

    public static func spread(_ value: FloatList) -> Float {
        return Math.centralMoments(value).m2
    }

    public static func crest(_ value: FloatList) -> Float {
        let energy = Math.energy(value)
        if energy > 0 {
            return Atoll.max(value) / Atoll.mean(value)
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
