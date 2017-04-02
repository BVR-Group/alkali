//
//  UIColor+.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 4/2/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public typealias ARGBTuple = (a: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat)
    public typealias HSBATuple = (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)

    public var ARGBColorValues: ARGBTuple {
        var result: ARGBTuple = (a: 0, r: 0, g: 0, b: 0)
        guard self.getRed(&result.r, green: &result.g, blue: &result.b, alpha: &result.a) else {
            fatalError("Unable to convert color!")
        }
        return result
    }

    public var HSBAColorValues: HSBATuple {
        var result: HSBATuple = (h: 0, s: 0, b: 0, a: 0)
        guard self.getHue(&result.h, saturation: &result.s, brightness: &result.b, alpha: &result.a) else {
            fatalError("Unable to convert color!")
        }
        return result
    }

    public convenience init(from tuple: ARGBTuple) {
        self.init(red: tuple.r, green: tuple.g, blue: tuple.b, alpha: tuple.a)
    }

    public convenience init(from tuple: HSBATuple) {
        self.init(hue: tuple.h, saturation: tuple.s, brightness: tuple.b, alpha: tuple.a)
    }

    private static func lerp(from a: CGFloat, to b: CGFloat, percent: CGFloat) -> CGFloat {
        return (b - a) * percent + a
    }

    public typealias ColorInterpolationFunction = (UIColor, UIColor, CGFloat) -> UIColor

    public static func interpolateARGB(from a: UIColor, to b: UIColor, percent: CGFloat) -> UIColor {
        let tempA = a.ARGBColorValues
        let tempB = b.ARGBColorValues
        var result: ARGBTuple = (a: 0, r: 0, g: 0, b: 0)
        result.a = UIColor.lerp(from: tempA.a, to: tempB.a, percent: percent)
        result.r = UIColor.lerp(from: tempA.r, to: tempB.r, percent: percent)
        result.g = UIColor.lerp(from: tempA.g, to: tempB.g, percent: percent)
        result.b = UIColor.lerp(from: tempA.b, to: tempB.b, percent: percent)
        return UIColor(from: result)
    }

    public static func interpolateHSBA(from a: UIColor, to b: UIColor, percent: CGFloat) -> UIColor {
        var tempA = a.HSBAColorValues
        var tempB = b.HSBAColorValues
        var result: HSBATuple = (h: 0, s: 0, b: 0, a: 0)
        var delta = tempB.h - tempA.h
        var p = percent

        if tempA.h > tempB.h {
            let temp = tempB
            tempB = tempA
            tempA = temp

            delta = -1 * delta
            p = 1 - percent
        }

        if delta > 0.5 {
            tempA.h = tempA.h + 1.0
            result.h = (tempA.h + p * (tempB.h - tempA.h))
        }

        if delta <= 0.5 {
            result.h = tempA.h + p * delta
        }

        result.s = UIColor.lerp(from: tempA.s, to: tempB.s, percent: p)
        result.b = UIColor.lerp(from: tempA.b, to: tempB.b, percent: p)
        result.a = UIColor.lerp(from: tempA.a, to: tempB.a, percent: p)

        return UIColor(from: result)
    }

    public func interpolate(to color: UIColor, percent: CGFloat, using function: ColorInterpolationFunction) -> UIColor {
        return function(self, color, percent)
    }

    public func ramp(through color: UIColor, with steps: Int, using function: ColorInterpolationFunction) -> [UIColor] {
        let stepSize = 1.0 / Double(steps)
        var result = [UIColor]()
        for i in stride(from: 0.0, through: 1.0, by: stepSize) {
            result.append(self.interpolate(to: color, percent: CGFloat(i), using: function))
        }
        return result
    }
    
}
