//: [Previous](@previous)

import Foundation
import Alkali
import UIKit

let size = (width: 16, height: 16)
var pixelData = PixelBuffer.testPattern(size)
let original = UIImage.from(pixelData)
let image = UIImage.init(cgImage: original!.cgImage!, scale: original!.scale * 0.0625, orientation: original!.imageOrientation)


UIImageView(image: image)

//
//dump(pixelData.data)

//: [Next](@next)
