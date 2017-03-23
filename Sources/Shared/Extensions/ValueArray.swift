//
//  ValueArray.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/9/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Upsurge

extension ValueArray {
    public var vDSPLength: vDSP_Length {
        return vDSP_Length(count)
    }
}

extension ValueArray where Element == Double {

    public convenience init(zeros n: Int) {
        self.init(count: n, repeatedValue: 0.0)
    }

    public convenience init(ones n: Int) {
        self.init(count: n, repeatedValue: 1.0)
    }

    /// Creates a ```ValueArray``` of ```Double``` using Accelerate, through a ```ClosedRange```.
    public convenience init(rampingThrough range: ClosedRange<Element>, by increment: Element) {
        let n = Int(((range.upperBound - range.lowerBound) / increment))
        let result = ValueArray<Element>(zeros: n)
        var increase = increment
        var from = range.lowerBound

        result.withUnsafeMutablePointer { (pointer) -> Void in
            vDSP_vrampD(&from, &increase, pointer, 1, result.vDSPLength)
        }

        self.init(result)
    }
}

extension ValueArray where Element == Float {

    public convenience init(zeros n: Int) {
        self.init(count: n, repeatedValue: 0.0)
    }

    public convenience init(ones n: Int) {
        self.init(count: n, repeatedValue: 1.0)
    }

    /// Creates a ```ValueArray``` of ```Float``` using Accelerate, through a ```ClosedRange```.
    public convenience init(rampingThrough range: ClosedRange<Element>, by increment: Element) {
        let n = Int(((range.upperBound - range.lowerBound) / increment))
        let result = ValueArray<Element>(zeros: n)
        var increase = increment
        var from = range.lowerBound

        result.withUnsafeMutablePointer { (pointer) -> Void in
            vDSP_vramp(&from, &increase, pointer, 1, result.vDSPLength)
        }

        self.init(result)
    }

    public var halfIndex: ValueArray.Index {
        return self.endIndex / 2
    }

    public var firstHalf: ValueArraySlice<Element> {
        return self[startIndex..<halfIndex]
    }

    public func mirror() {
        self[halfIndex...endIndex] = ValueArraySlice<Element>(base: FloatBuffer(self[startIndex..<halfIndex].reversed()),
                                                              startIndex: startIndex,
                                                              endIndex: halfIndex,
                                                              step: 1)
    }
}
