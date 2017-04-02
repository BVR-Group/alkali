//: [Previous](@previous)

import Foundation
import Alkali
import UIKit
import Accelerate
import AVFoundation
import PlaygroundSupport
import Upsurge

PlaygroundPage.current.needsIndefiniteExecution = true


let size = CGSize(width: 128, height: 128)
if let audioPath = Bundle.main.path(forResource: "DoomTest", ofType: "wav") {
    let audioURL = URL(fileURLWithPath: audioPath)
    let image = drawSpectrogram(of: size, from: audioURL)

}


extension Array {
    func asPairs() -> [(Iterator.Element, Iterator.Element)] {
        var result: [(Iterator.Element, Iterator.Element)] = []
        for (i, value) in self.enumerated() {
            if i < count - 1 {
                result.append((value, self[i + 1]))
            }
        }
        return result
    }

}

func rampARGB(pair: (UIColor, UIColor), steps: Int) -> [UIColor] {
    return pair.0.ramp(through: pair.1, with: steps, using: UIColor.interpolateARGB)
}

func rampHSBA(pair: (UIColor, UIColor), steps: Int) -> [UIColor] {
    return pair.0.ramp(through: pair.1, with: steps, using: UIColor.interpolateHSBA)
}


func spectrum(from colors: [UIColor], steps: Int) -> [UIColor] {
    var result = [UIColor]()

    let pairs = colors.asPairs()

    for (index, pair) in pairs.enumerated() {
        var subRamp = pair.0.ramp(through: pair.1, with: steps, using: UIColor.interpolateHSBA)

        if index != pairs.endIndex - 1 {
            subRamp = Array(subRamp.dropLast(1))
        }
        result.append(contentsOf: subRamp)
    }
    return result
}

extension UIColor {
    class var pistachio: UIColor {
        return UIColor(red: 134.0/255.0, green: 203.0/255.0, blue: 146.0/255.0, alpha: 1.0)
    }
}

//let steps = 8
//let colors:[UIColor] = [.blue, .red, .orange, .black, .pistachio]
//var canvas = PixelCanvas(of: CGSize(width: steps * colors.count, height: 1))
//canvas.size
//
//for (index, color) in spectrum(from: colors , steps: steps).enumerated() {
//    canvas[index, 0] = color
//}
//
//canvas.image?.resized(to: CGSize(width: canvas.size.width * 32, height: canvas.size.height * 64))


//audioPlayer?.play()

//
//dump(pixelData.data)

//: [Next](@next)
