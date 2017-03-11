//: Playground - noun: a place where people can play
import Foundation
import Alkali
import Upsurge

let size: Int = 15


let win = Window.bartlett
let buffer: ValueArray<Float> = win.buffer(12)
buffer.map { $0 }
