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

    /// Computes the peak energy of the magnitude spectrum.
    public func peakEnergy() -> Float {
        return Math.peakEnergy(magnitudeSpectrum)
    }

    /// Computes the rolloff of the magnitude spectrum.
    ///
    public func rolloff() -> Float {
        return Math.rolloff(magnitudeSpectrum)
    }
    
    /// Computes the flatness of the magnitude spectrum.
    ///
    public func flatness() -> Float {
        return Math.flatness(magnitudeSpectrum)
    }

    /// Computes the spectral centroid of the magnitude spectrum.
    ///
    public func centroid() -> Float {
        return Math.centroid(magnitudeSpectrum)
    }

    /// Computes the root mean square (RMS) of the current buffer.
    ///
    public func rootMeanSquare() -> Float {
        guard let currentBuffer = currentBuffer else {
            fatalError("No buffer to analyze!")
        }
        return Math.rootMeanSquare(currentBuffer)
    }
}
