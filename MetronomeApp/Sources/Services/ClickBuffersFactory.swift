//
//  ClickBuffersFactory.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 01.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation

protocol ClickBuffersFactoryType: Sendable {
    /// Reads both click files of the sample into buffers in `AVAudioFormat.metronome`.
    func makeBuffers(for clickSample: ClickSample) -> ClickBuffers
}

struct ClickBuffers {
    let accented: AVAudioPCMBuffer
    let regular: AVAudioPCMBuffer

    func buffer(for click: Beat.Click) -> AVAudioPCMBuffer {
        switch click {
        case .accented: accented
        case .regular: regular
        }
    }
}

struct ClickBuffersFactory: ClickBuffersFactoryType {
    func makeBuffers(for clickSample: ClickSample) -> ClickBuffers {
        ClickBuffers(
            accented: makeBuffer(reading: clickSample.accentedFile),
            regular: makeBuffer(reading: clickSample.regularFile)
        )
    }

    private func makeBuffer(reading file: AVAudioFile) -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: .metronome, frameCapacity: AVAudioFrameCount(file.length))!
        try! file.read(into: buffer)
        return buffer
    }
}
