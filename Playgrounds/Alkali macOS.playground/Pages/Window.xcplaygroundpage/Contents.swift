//: Playground - noun: a place where people can play
import Foundation
import Alkali
import Upsurge

let size: Window.Length = 32

let cosWindow: DoubleBuffer = Window.cosine.buffer(size)
cosWindow.map { $0 }

let rectWindow: DoubleBuffer = Window.rectangle.buffer(size)
rectWindow.map { $0 }

let lancWindow: DoubleBuffer = Window.lanczos.buffer(size)
lancWindow.map { $0 }


let triWindow: FloatBuffer = Window.triangle.buffer(size)
triWindow.map { $0 }

// Doesn't use accelerate!
let bartlettWindow: FloatBuffer = Window.bartlett.buffer(size)
bartlettWindow.map { $0 }

// Doesn't use accelerate!
let gaussianWindow: DoubleBuffer = Window.gaussian(sigma: 0.12345).buffer(size)
gaussianWindow.map { $0 }

let hanningWindow: FloatBuffer = Window.hanning.buffer(size)
hanningWindow.map { $0 }

let hammingWindow: FloatBuffer = Window.hamming.buffer(size)
hammingWindow.map { $0 }

