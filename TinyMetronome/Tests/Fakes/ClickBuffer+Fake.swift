//
//  ClickBuffer+Fake.swift
//  TinyMetronomeTests
//
//  Created by Alex Shubin on 02.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation
@testable import TinyMetronome

extension ClickBuffer {
    /// A distinct, empty buffer; every call is a new identity.
    static func fake() -> ClickBuffer {
        ClickBuffer(pcm: AVAudioPCMBuffer(pcmFormat: .metronome, frameCapacity: 1)!)
    }
}
