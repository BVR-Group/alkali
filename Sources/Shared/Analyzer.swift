//
//  Analyzer.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/19/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Atoll

public final class Analyzer: FFT {
    internal var currentBuffer: FloatList? = nil

    public func process(frames: FloatList) {
        currentBuffer = frames
        super.transform(buffer: frames)
    }
}
