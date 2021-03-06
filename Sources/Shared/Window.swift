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

func sinc(_ x: Double) -> Double {
    return x == 0 ? 1 : sin(x) / x
}

func sinc(_ x: Float) -> Float {
    return x == 0 ? 1 : sinf(x) / x
}

public enum Window {
    public typealias Length = vDSP_Length

    /// Represents a Hanning window
    case hanning

    /// Represents a Hamming window
    case hamming

    /// Represents a Blackman window
    case blackman

    case gaussian(sigma: Double)

    case bartlett

    case triangle

    case lanczos

    case rectangle

    case cosine

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
        let R = 0..<Int(length)
        switch self {
        case .gaussian(let sigma):
            assert(sigma <= 0.5, "sigma must be greater than 0 and less than 0.5!")

            for i in R {
                let I = Double(i)
                result[i] = exp(-0.5 * pow(((I - (N - 1) / 2)/(sigma * (N - 1 / 2))),2))
            }
        case .bartlett:
            for i in R {
                let I = Double(i)
                result[i] = 2 / (N - 1) * ((N - 1) / 2 - abs(I - (N - 1) / 2))
            }
        case .triangle:
            for i in R {
                let I = Double(i)
                result[i] = 1 - abs((I - (N - 1) / 2)) / (N / 2)
            }
        case .lanczos:
            for i in R {
                let I = Double(i)
                result[i] = sinc(Double.pi * (2 * I / (N - 1) - 1))
            }
        case .rectangle:
            for i in R {
                result[i] = 1.0
            }
        case .cosine:
            for i in R {
                let I = Double(i)
                result[i] = sin(Double.pi * I / (N - 1))
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
        let R = 0..<Int(length)
        switch self {
        case .gaussian(let sigma):
            assert(sigma <= 0.5, "sigma must be greater than 0 and less than 0.5!")

            let S = Float(sigma)
            for i in R {
                let I = Float(i)
                result[i] = exp(-0.5 * powf(((I - (N - 1) / 2)/(S * (N - 1 / 2))),2))
            }
        case .bartlett:
            for i in R {
                let I = Float(i)
                result[i] = 2 / (N - 1) * ((N - 1) / 2 - abs(I - (N - 1) / 2))
            }
        case .triangle:
            for i in R {
                let I = Float(i)
                result[i] = 1 - abs((I - (N - 1) / 2)) / (N / 2)
            }
        case .lanczos:
            for i in R {
                let I = Float(i)
                result[i] = sinc(Float.pi * (2 * I / (N - 1) - 1))
            }
        case .rectangle:
            for i in R {
                result[i] = 1.0
            }
        case .cosine:
            for i in R {
                let I = Float(i)
                result[i] = sinf(Float.pi * I / (N - 1))
            }
        default:
            break
        }
        return result
    }
}
