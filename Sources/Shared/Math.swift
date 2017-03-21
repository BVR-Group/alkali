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
    public func dBs() -> Decibel {
        return Math.dB(from: self)
    }
}

extension Decibel {
    public func amps() -> Amp {
        return Math.amp(from: self)
    }
}
