//
//  SampleBuffer.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 4/2/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//
import Foundation
import AVFoundation

public struct SampleBuffer {
    public var data = Data()

    public var samplesToProcess: Int {
        return data.count / MemoryLayout<Int8>.size
    }

    public var duration: Float {
        return (Float(samplesToProcess) / 44100.0) / 2.0
    }

    public init(from url: URL) {

        
    }
}
