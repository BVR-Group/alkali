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

    /// Computes the peak energy of the current frame.
    public func peakEnergy() -> Float {
        guard let currentBuffer = currentBuffer else {
            fatalError("No buffer to analyze!")
        }
        return Math.peakEnergy(currentBuffer)
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

    /// Computes the spectral kurtosis of the magnitude spectrum.
    ///
    /// - note: The kurtosis gives a measure of how flat a distribution of values are around its
    ///         mean value.
    ///     - K = 3 for normal distribution.
    ///     - K < 3 for flatter distribution.
    ///     - K > 3 for a peak distribution.
    ///
    public func kurtosis() -> Float {
        return Math.kurtosis(magnitudeSpectrum)
    }

    /// Computes the spectral skewness of the magnitude spectrum.
    ///
    /// - note: The skewness gives a measure of the asymmetry of a distribution of values are around
    ///         its mean value.
    ///     - SK = 0 indicates summetric distribution.
    ///     - SK < 0 indicates more energy on the right.
    ///     - SK > 0 indicates more energy on the left.
    ///
    public func skewness() -> Float {
        return Math.kurtosis(magnitudeSpectrum)
    }

    /// Computes the spectral spread of the magnitude spectrum.
    ///
    /// - note: The skewness gives a measure of the spread of the spectrum around its mean value.
    ///
    public func spread() -> Float {
        return Math.kurtosis(magnitudeSpectrum)
    }

    /// Computes the spectral crest of the magnitude spectrum.
    ///
    public func crest() -> Float {
        return Math.crest(magnitudeSpectrum)
    }
}
