//
//  Analyzer+Temporal.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/19/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Upsurge

extension Analyzer {

    /// Returns the zero-crossing rate of the current buffer in the analyzer. A high zero-crossing
    /// rate is a good indicator of a noisey signal.

    public func zeroCrossingRate() -> Int {
        guard let current = currentBuffer else {
            fatalError("No buffer to analyze!")
        }
        var result: vDSP_Length = 0
        var lastIndex: vDSP_Length = 0
        vDSP_nzcros(current.pointer, 1, current.vDSPLength, &lastIndex, &result, current.vDSPLength)
        return Int(result)
    }

    /// Returns the Steven's power law value of "Loudness" (energy ^ 0.67).
    ///

    public func loudness() -> Float {
        guard let current = currentBuffer else {
            fatalError("No buffer to analyze!")
        }
        return powf(Math.energy(current), 0.67)
    }
}
