//
//  DSP.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/8/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Accelerate
import Upsurge

public enum Window<T: ExpressibleByFloatLiteral> {
    public typealias Length = vDSP_Length

    /// Represents a Hanning window
    case hanning

    /// Represents a Hanning window
    case hamming

    case blackman

}

extension Window where T == Double {

    var function: (UnsafeMutablePointer<T>, vDSP_Length, Int32) -> Void {
        switch self {
        case .hamming:
            return vDSP_hamm_windowD
        case .hanning:
            return vDSP_hann_windowD
        case .blackman:
            return vDSP_blkman_windowD
        }
    }


    /// Returns a ```[Double]``` of the given length from this ```Window``` type.
    public func buffer(of length: Length) -> [Double] {
        var result = [Double](repeating: 0, count: Int(length))
        function(&result, length, 0)
        return result
    }
}

extension Window where T == Float {

    var function: (UnsafeMutablePointer<T>, vDSP_Length, Int32) -> Void {
        switch self {
        case .hamming:
            return vDSP_hamm_window
        case .hanning:
            return vDSP_hann_window
        case .blackman:
            return vDSP_blkman_window
        }
    }

    /// Returns a ```[Float]``` of the given length from this ```Window``` type.
    public func buffer(of length: Length) -> [Float] {
        var result = [Float](repeating: 0, count: Int(length))
        function(&result, length, 0)
        return result
    }
}
