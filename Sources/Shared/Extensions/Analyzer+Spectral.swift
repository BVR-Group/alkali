//
//  Analyzer+Spectral.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/19/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Upsurge

extension Analyzer {

    /// Computes the root mean square (RMS) of the current buffer.
    ///
    public func rootMeanSquare() -> Float {
        guard let currentBuffer = currentBuffer else {
            fatalError("No buffer to analyze!")
        }
        var result: Float = 0
        currentBuffer.withUnsafePointer { ptr in
            vDSP_rmsqv(ptr, 1, &result, Length(self.n))
        }
        return result
    }
}
