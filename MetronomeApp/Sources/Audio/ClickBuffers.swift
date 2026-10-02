//
//  ClickBuffers.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 02.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation

/// A loaded click, ready to be scheduled. Compared by identity.
struct ClickBuffer: Equatable {
    let pcm: AVAudioPCMBuffer
}

struct ClickBuffers {
    let accented: ClickBuffer
    let regular: ClickBuffer
}
