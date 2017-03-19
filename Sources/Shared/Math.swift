//
//  Math.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/19/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import Upsurge

func energy<T: LinearType>(_ x: T) -> Double where T.Element == Double {
    return innerProduct(x, x)
}

func energy<T: LinearType>(_ x: T) -> Float where T.Element == Float {
    return innerProduct(x, x)
}

func innerProduct<T: LinearType>(_ x: T, _ y: T) -> Double where T.Element == Double {
    return sum(x * y)
}

func innerProduct<T: LinearType>(_ x: T, _ y: T) -> Float where T.Element == Float {
    return sum(x * y)
}
