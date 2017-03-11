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

public enum Window {
    public typealias Length = vDSP_Length

    /// Represents a Hanning window
    case hanning

    /// Represents a Hamming window
    case hamming

    /// Represents a Blackman window
    case blackman

    case gaussian

    case bartlett

    /// Returns a ```DoubleBuffer``` of a given ```Length``` and type.
    public func buffer(_ length: Length) -> DoubleBuffer {
        let result = DoubleBuffer(count: Int(length), repeatedValue: 0.0)
        result.withUnsafeMutablePointer { (pointer) -> Void in
            switch self {
            case .hamming:
                vDSP_hamm_windowD(pointer, length, 0)
            case .hanning:
                vDSP_hann_windowD(pointer, length, 0)
            case .blackman:
                vDSP_blkman_windowD(pointer, length, 0)
            default:
                return
            }
        }

        let N = Double(length)
        switch self {
        case .gaussian:
            for i in 0..<Int(length) {
                let I = Double(i)
                result[i] = exp(-1.0 * (2.0 * I - N + 1.0) * (2.0 * I - N + 1.0) / ((N - 1.0) * (N - 1.0)))
            }
        case .bartlett:
            for i in 0..<Int(length) {
                let I = Double(i)
                result[i] = 1.0 - abs((2.0 * I - N + 1.0) / (N - 1.0))
            }
        default:
            break
        }
        return result
    }

    /// Returns a ```FloatBuffer``` of a given ```Length``` and type.
    public func buffer(_ length: Length) -> FloatBuffer {
        let result = FloatBuffer(count: Int(length), repeatedValue: 0.0)
        result.withUnsafeMutablePointer { (pointer) -> Void in
            switch self {
            case .hamming:
                vDSP_hamm_window(pointer, length, 0)
            case .hanning:
                vDSP_hann_window(pointer, length, 0)
            case .blackman:
                vDSP_blkman_window(pointer, length, 0)
            default:
                return
            }
        }

        let N = Float(length)
        switch self {
        case .gaussian:
            for i in 0..<Int(length) {
                let I = Float(i)
                result[i] = expf(-1.0 * (2.0 * I - N + 1.0) * (2.0 * I - N + 1.0) / ((N - 1.0) * (N - 1.0)))
            }
        case .bartlett:
            for i in 0..<Int(length) {
                let I = Float(i)
                result[i] = 1.0 - abs((2.0 * I - N + 1.0) / (N - 1.0))
            }
        default:
            break
        }
        return result
    }
}
