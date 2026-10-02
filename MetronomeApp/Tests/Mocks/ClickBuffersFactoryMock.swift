//
//  ClickBuffersFactoryMock.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 02.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation
@testable import MetronomeApp

final class ClickBuffersFactoryMock: ClickBuffersFactoryType, @unchecked Sendable {
    enum Calls: Equatable {
        case makeBuffers(ClickSample)
    }

    private(set) var calls: [Calls] = []

    var makeBuffersResult = ClickBuffers(accented: .empty, regular: .empty)
    func makeBuffers(for clickSample: ClickSample) -> ClickBuffers {
        calls.append(.makeBuffers(clickSample))
        return makeBuffersResult
    }
}

extension AVAudioPCMBuffer {
    /// A distinct, empty buffer; tests compare buffers by identity.
    static var empty: AVAudioPCMBuffer {
        AVAudioPCMBuffer(pcmFormat: .metronome, frameCapacity: 1)!
    }
}
