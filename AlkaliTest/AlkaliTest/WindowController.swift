//
//  WindowController.swift
//  AlkaliTest
//
//  Created by Dylan Wreggelsworth on 12/28/17.
//  Copyright © 2017 Dylan Wreggelsworth. All rights reserved.
//

import Foundation
import AppKit

class WindowController: NSWindowController {
    override func windowDidLoad() {
        window?.titlebarAppearsTransparent = true
        
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: window!.frame.width, height: window!.frame.height))
        visualEffectView.material = .appearanceBased
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .followsWindowActiveState
        
        guard let contentView = window?.contentView else { return }
        contentView.addSubview(visualEffectView, positioned: .below, relativeTo: contentView.subviews.first)

        window?.appearance = NSAppearance(named: .vibrantDark)
        window?.invalidateShadow()
    }
}
