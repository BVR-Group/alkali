//: Playground - noun: a place where people can play
import Foundation
import Alkali
import Atoll
import simd

let size: Window.Length = 32

let cosWindow: DoubleList = Window.cosine.buffer(size)
cosWindow.map { $0 }

let rectWindow: DoubleList = Window.rectangle.buffer(size)
rectWindow.map { $0 }

let lancWindow: DoubleList = Window.lanczos.buffer(size)
lancWindow.map { $0 }


let triWindow: FloatList = Window.triangle.buffer(size)
triWindow.map { $0 }

// Doesn't use accelerate!
let bartlettWindow: FloatList = Window.bartlett.buffer(size)
bartlettWindow.map { $0 }

// Doesn't use accelerate!
let gaussianWindow: DoubleList = Window.gaussian(sigma: 0.12345).buffer(size)
gaussianWindow.map { $0 }

let hanningWindow: FloatList = Window.hanning.buffer(size)
hanningWindow.map { $0 }

let hammingWindow: FloatList = Window.hamming.buffer(size)
hammingWindow.map { $0 }

