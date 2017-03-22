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

    /// Computes the centroid of a ```ValueArray```.
    ///
    public static func centroid(of value: ValueArray<Float>) -> Float {
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
        return geometricMean(x + 1) / mean(x + 1)
    }

    public static func geometricMean<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return exp(sum(log(x)) / Float(x.count))
    }

    public static func rootMeanSquare<T: LinearType>(_ x: T) -> Float where T.Element == Float {
        return rmsq(x)
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
