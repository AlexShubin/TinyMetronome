//
//  ClickBuffersFactory.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 01.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation

protocol ClickBuffersFactoryType: Sendable {
    /// Reads both click files of the sample into buffers in `AVAudioFormat.metronome`.
    func makeBuffers(for clickSample: ClickSample) -> ClickBuffers
}

struct ClickBuffersFactory: ClickBuffersFactoryType {
    func makeBuffers(for clickSample: ClickSample) -> ClickBuffers {
        let regular = makeBuffer(reading: clickSample.regularFile)
        return ClickBuffers(
            accented: makeBuffer(reading: clickSample.accentedFile),
            regular: regular,
            silent: makeSilence(frames: regular.pcm.frameLength)
        )
    }

    private func makeBuffer(reading file: AVAudioFile) -> ClickBuffer {
        let pcm = AVAudioPCMBuffer(pcmFormat: .metronome, frameCapacity: AVAudioFrameCount(file.length))!
        try! file.read(into: pcm)
        return ClickBuffer(pcm: pcm)
    }

    private func makeSilence(frames: AVAudioFrameCount) -> ClickBuffer {
        let pcm = AVAudioPCMBuffer(pcmFormat: .metronome, frameCapacity: frames)!
        pcm.frameLength = frames
        pcm.floatChannelData!.pointee.update(repeating: 0, count: Int(frames))
        return ClickBuffer(pcm: pcm)
    }
}

private extension ClickSample {
    var accentedFile: AVAudioFile {
        let name: String = switch self {
        case .classic: "Classic Accented"
        case .digital: "Digital Accented"
        case .logicStyle: "Logic Style Accented"
        }
        return try! AVAudioFile(forReading: Bundle.main.url(forResource: name, withExtension: "wav")!)
    }

    var regularFile: AVAudioFile {
        let name: String = switch self {
        case .classic: "Classic Regular"
        case .digital: "Digital Regular"
        case .logicStyle: "Logic Style Regular"
        }
        return try! AVAudioFile(forReading: Bundle.main.url(forResource: name, withExtension: "wav")!)
    }
}
