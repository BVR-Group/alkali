//: [Previous](@previous)

import Foundation
import Alkali
import UIKit

let size = (width: 12, height: 12)
var pixelData = PixelBuffer.testPattern(size)
let original = UIImage.from(pixelData)?.resize(size: CGSize(width: 256, height: 256))

UIImageView(image: original)


//
//dump(pixelData.data)

//: [Next](@next)
