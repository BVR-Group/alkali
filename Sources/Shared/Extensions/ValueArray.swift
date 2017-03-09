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

    public convenience init(rampingThrough range: ClosedRange<Element>, by increase: Element) {
        let n = Int(((range.upperBound - range.lowerBound) / increase))
        let result = ValueArray<Element>(zeros: n)
        var increase = increase
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

    public convenience init(rampingThrough range: ClosedRange<Element>, by increase: Element) {
        let n = Int(((range.upperBound - range.lowerBound) / increase))
        let result = ValueArray<Element>(zeros: n)
        var increase = increase
        var from = range.lowerBound

        result.withUnsafeMutablePointer { (pointer) -> Void in
            vDSP_vramp(&from, &increase, pointer, 1, result.vDSPLength)
        }

        self.init(result)
    }
}
