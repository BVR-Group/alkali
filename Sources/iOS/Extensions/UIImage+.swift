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

public typealias Size = (width: Int, height: Int)

extension UIImage {
    public func resized(to size: CGSize) -> UIImage? {
        let destWidth = size.width
        let destHeight = size.height
        let alphaInfo = CGImageAlphaInfo.premultipliedFirst
        guard let context = CGContext(data: nil, width: Int(destWidth), height: Int(destHeight), bitsPerComponent: 8, bytesPerRow: Int(destWidth) * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: alphaInfo.rawValue),
        let originalCGImage = self.cgImage else {
            return nil
        }
        context.setShouldAntialias(false)
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none

        UIGraphicsPushContext(context)
        context.draw(originalCGImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsPopContext()

        guard let newCGImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: newCGImage)
    }
}

