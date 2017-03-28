//: [Previous](@previous)

import Foundation
import Alkali
import UIKit
let dimension = 16

let size = CGSize(width: dimension, height: dimension)
var pixelData = PixelCanvas.testPattern(size)

//pixelData.line(from: CGPoint(x: 3, y:3), to: CGPoint(x: 10,y: 10), color: .red)
pixelData
    .line(from: CGPoint(x: 0, y: 8), to: CGPoint(x: 8, y: 0), with: .black)
    .line(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 8, y: 8), with: .red)
    .line(from: CGPoint(x: 4, y: 0), to: CGPoint(x: 4, y: 3), with: .blue)

pixelData[8, 8] = .green

let original = pixelData.image?.resized(to: CGSize(width: 256, height: 256))

let newImage = pixelData
pixelData[9, 8] = .green

UIImageView(image: newImage.image?.resized(to: CGSize(width: 256, height: 256)))
UIImageView(image: original)


//
//dump(pixelData.data)

//: [Next](@next)
