//
//  PixelCanvas.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/28/17.
//  Copyright © 2017 BVR, LLC. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

func /(left: UInt8, right: Float) -> Float {
    return Float(left) / right
}

extension CGFloat {
    public var toUInt8:UInt8 {
        return UInt8(self * 255.0)
    }
}

extension UIColor {
    public func toUInt8() -> Pixel_8888 {
        let ciColor = CIColor(color: self)
        let (alpha, red, green, blue) = (ciColor.alpha, ciColor.red, ciColor.green, ciColor.blue)
        return (red.toUInt8, green.toUInt8, blue.toUInt8, alpha.toUInt8)
    }
}

/// A CoreImage backed canvas type.
///
/// - authors:
///     Thanks to [BitmapCanvas](https://github.com/nst/BitmapCanvas) for the example.
///
public struct PixelCanvas {

    let context: CGContext

    public let size: CGSize

    public init(of size: CGSize) {
        self.size = size
        let bitsPerComponent = 8
        let bytesPerPixel    = 4
        let bytesPerRow      = bytesPerPixel * Int(size.width)
        self.context = CGContext(data: nil,
                                 width: Int(size.width),
                                 height: Int(size.height),
                                 bitsPerComponent: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 space: CGColorSpaceCreateDeviceRGB(),
                                 bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
        context.setShouldAntialias(false)
        context.setAllowsAntialiasing(false)
    }

    public subscript(x: Int, y: Int) -> UIColor {
        get {
            let data = context.data!.assumingMemoryBound(to: UInt8.self)
            return fetchColor(x: x, y: y, in: data)
        }
        set {
            let data = context.data!.assumingMemoryBound(to: UInt8.self)
            setColor(x, y, newValue, in: data)
        }
    }
    private func setColor(_ x: Int, _ y: Int, _ color: UIColor, in pointer: UnsafeMutablePointer<UInt8>) {
        let offset = 4 * (Int(size.width) * y + x)
        let uintColor       = color.toUInt8()

        pointer[offset]     = uintColor.3
        pointer[offset + 1] = uintColor.0
        pointer[offset + 2] = uintColor.1
        pointer[offset + 3] = uintColor.2
        //        print("a: \(pointer[offset]), r: \(pointer[offset+1]), g: \(pointer[offset+2]), b: \(pointer[offset+3])")
    }

    private func fetchColor(x: Int, y: Int, in pointer: UnsafePointer<UInt8>) -> UIColor {
        let offset = 4 * (Int(size.width) * y + x)
        let a = pointer[offset]
        let r = pointer[offset + 1]
        let g = pointer[offset + 2]
        let b = pointer[offset + 3]
        //        print("a: \(a), r: \(r), g: \(g), b: \(b)")
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }

    public static func testPattern(_ size: CGSize) -> PixelCanvas {
        var pixelData = PixelCanvas(of: size)
        for i in 0..<Int(size.height) {
            for j in 0..<Int(size.width) {
                let r = Float(i) / Float(size.height)
                let g = Float(j) / Float(size.width)
                pixelData[i, j] = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(0.5), alpha: 1.0)
            }
        }
        return pixelData
    }

    public var image: UIImage? {
        guard let image = self.context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: image)
    }

    public func line(from x: CGPoint, to y: CGPoint, with color: UIColor) -> PixelCanvas {
        UIGraphicsPushContext(context)
        context.setStrokeColor(color.cgColor)
        context.strokeLineSegments(between: [x,y])
        UIGraphicsPopContext()
        return self
    }
}
