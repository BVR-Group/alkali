//: Playground - noun: a place where people can play
import Foundation
import Alkali
import Upsurge

let size: Window.Length = 15

// Doesn't use accelerate!
let bartlettWindow: FloatBuffer = Window.bartlett.buffer(size)
bartlettWindow.map { $0 }

// Doesn't use accelerate!
let gaussianWindow: FloatBuffer = Window.gaussian.buffer(size)
gaussianWindow.map { $0 }

let hanningWindow: FloatBuffer = Window.hanning.buffer(size)
hanningWindow.map { $0 }

let hammingWindow: FloatBuffer = Window.hamming.buffer(size)
hammingWindow.map { $0 }

