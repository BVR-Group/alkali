//
//  FFTViewController.swift
//  AlkaliTest
//
//  Created by Dylan Wreggelsworth on 12/27/17.
//  Copyright © 2017 Dylan Wreggelsworth. All rights reserved.
//

import AppKit
import AVFoundation
import Alkali
import Atoll

class FFTViewController: NSViewController {
    let analyzer = Analyzer(size: 512, sampleRate: 44100)
    let player = AVAudioPlayerNode()
    let engine = AVAudioEngine()
    
    @IBOutlet weak var stackView: NSStackView!
    
    var graph1: GraphView? = nil
    var graph2: GraphView? = nil

    var displayLink: CVDisplayLink?
    var mags: [Float] = []
    var peakEnergy: [Float] = []
    
    override func viewDidLoad() {

        graph1 = GraphView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 400, height: 150)))
        graph1!.graphType = .line
        graph1!.isAutoscaling = false
        graph1!.visibleRange = 0...200
        graph1!.backgroundTint = .clear
        graph1!.title = "Mag. Spectrum"
        graph1!.sampleColor = .gradient(top: .red, bottom: .blue)

        stackView.addArrangedSubview(graph1!)
        
        stackView.addConstraint(
            NSLayoutConstraint(
                item: graph1!,
                attribute: .width,
                relatedBy: .equal,
                toItem: stackView,
                attribute: .width,
                multiplier: 1.0,
                constant: 0)
        )
        
        graph2 = GraphView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 400, height: 150)))
        graph2!.graphType = .line
        graph2!.backgroundTint = .clear
        graph2!.title = "Peak Energy"
        graph2!.sampleColor = .gradient(top: .red, bottom: .green)

        stackView.addArrangedSubview(graph2!)
        
        stackView.addConstraint(
            NSLayoutConstraint(
                item: graph2!,
                attribute: .width,
                relatedBy: .equal,
                toItem: stackView,
                attribute: .width,
                multiplier: 1.0,
                constant: 0)
        )

        engine.attach(player)
        engine.connect(player, to: engine.outputNode, format: nil)
        engine.prepare()
        try? engine.start()
        
        let fileURL = URL(fileReferenceLiteralResourceName: "Rolemusic_-_04_-_The_Pirate_And_The_Dancer.mp3")
        guard let audioFile = try? AVAudioFile.init(forReading: fileURL) else { return }
        
        player.scheduleFile(audioFile, at: nil) { [unowned self] in
            self.player.pause()
        }
        
        player.play()
        player.removeTap(onBus: 0)

        let tap: AVAudioNodeTapBlock = { [unowned self] (buffer, time) in
            buffer.frameLength = 512
            let ptr = buffer.floatChannelData![0].withMemoryRebound(to: Float.self, capacity: Int(buffer.frameLength)) { $0 }
            
            guard self.player.isPlaying else { return }
            
            self.analyzer.process(frames: FloatList(copyFrom: ptr, count: Int(buffer.frameLength)))
            self.mags = self.analyzer.magnitudeSpectrum.map({$0})
            self.peakEnergy.append(self.analyzer.peakEnergy())
        }
        
        player.installTap(onBus: 0, bufferSize: 512, format: player.outputFormat(forBus: 0), block: tap)
        
        func displayLinkOutputCallback(
            _ displayLink: CVDisplayLink,
            _ inNow: UnsafePointer<CVTimeStamp>,
            _ inOutputTime: UnsafePointer<CVTimeStamp>,
            _ flagsIn: CVOptionFlags,
            _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
            _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn
        {
            unsafeBitCast(displayLinkContext, to: FFTViewController.self).update()
            return kCVReturnSuccess
        }
        
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        
        guard displayLink != nil else { return }
        
        CVDisplayLinkSetOutputCallback(
            displayLink!,
            displayLinkOutputCallback,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        
        CVDisplayLinkStart(displayLink!)
    }

    @objc func update() {
        DispatchQueue.main.async { [unowned self] in
            self.graph1?.replace(with: self.mags)
            self.graph2?.replace(with: self.peakEnergy)
//            print(self.mags.reduce(into: 0, {
//                $0 = $0 > $1 ? $0 : $1
//            }))
        }
    }
}
