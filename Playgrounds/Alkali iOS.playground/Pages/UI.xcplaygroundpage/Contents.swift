//: [Previous](@previous)

import Foundation
import Alkali
import UIKit

let size = (width: 72, height: 72)
var pixelData = PixelBuffer.testPattern(size)
let image = UIImageView(image: UIImage.from(pixelData))
image
//
//dump(pixelData.data)

//: [Next](@next)
