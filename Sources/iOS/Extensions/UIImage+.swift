//
//  UIImage+.swift
//  Alkali
//
//  Created by Dylan Wreggelsworth on 3/27/17.
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
        guard let components = cgColor.components else {
            return (0,0,0,0)
        }
        return (components[0].toUInt8, components[1].toUInt8, components[2].toUInt8, components[3].toUInt8)
    }
}

public struct PixelBuffer {
    public var data: [UInt8]
    public let size: Size
    public var memorySize: Int {
        return MemoryLayout.size(ofValue: data)
    }

    public init(of size: Size) {
        self.data = [UInt8](repeating: 0, count: 32 * size.width * size.height)
        self.size = size
    }

    public subscript(x: Int, y: Int) -> UIColor {
        get {
            return Data(bytes: data).withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> UIColor in
                return fetchColor(x: x, y: y, in: data)
            }
        }
        set {
            var copy = Data(bytes: data)
            copy.withUnsafeMutableBytes { ptr in
                setColor(x, y, newValue, in: ptr)
            }
            data = Array(copy)
        }
    }
    private func setColor(_ x: Int, _ y: Int, _ color: UIColor, in pointer: UnsafeMutablePointer<UInt8>) {
        let offset = 4 * (size.width * y + x)

        let uintColor = color.toUInt8()
        pointer[offset] = uintColor.3
        pointer[offset + 1] = uintColor.0
        pointer[offset + 2] = uintColor.1
        pointer[offset + 3] = uintColor.2
        //        print("a: \(pointer[offset]), r: \(pointer[offset+1]), g: \(pointer[offset+2]), b: \(pointer[offset+3])")
    }

    private func fetchColor(x: Int, y: Int, in pointer: UnsafePointer<UInt8>) -> UIColor {
        let offset = 4 * (size.width * y + x)
        let a = pointer[offset]
        let r = pointer[offset + 1]
        let g = pointer[offset + 2]
        let b = pointer[offset + 3]
        //        print("a: \(a), r: \(r), g: \(g), b: \(b)")
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }

    public static func testPattern(_ size: Size) -> PixelBuffer {
        var pixelData = PixelBuffer(of: size)
        for i in 0..<size.height {
            for j in 0..<size.width {
                let value = Float(i) / Float(size.height)
                let value2 = Float(j) / Float(size.width)
                pixelData[i, j] = UIColor(red: CGFloat(value), green: CGFloat(value2), blue: CGFloat(0.5), alpha: 1.0)
            }
        }
        return pixelData
    }
}

public typealias Size = (width: Int, height: Int)

extension UIImage {
    public static func from(_ pixelBuffer: PixelBuffer) -> UIImage? {
        var pixelData = pixelBuffer.data
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue).union(CGBitmapInfo())
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * pixelBuffer.size.width
        let totalBytes = pixelBuffer.size.height * bytesPerRow

        let data = NSData(bytes: &pixelData, length: totalBytes)

        guard
            let provider = CGDataProvider(data: data),
            let cgImage = CGImage(width: pixelBuffer.size.width,
                                  height: pixelBuffer.size.height,
                                  bitsPerComponent: bitsPerComponent,
                                  bitsPerPixel: bitsPerPixel,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: bitmapInfo,
                                  provider: provider,
                                  decode: nil,
                                  shouldInterpolate: false,
                                  intent: .defaultIntent) else {
                                    return nil
        }
        return UIImage(cgImage: cgImage)
    }

    public func resize(size: CGSize) -> UIImage {
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        let resizedSize = CGSize(width: (self.size.width * ratio), height: (self.size.height * ratio))

        // 画質を落とさないように設定
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

