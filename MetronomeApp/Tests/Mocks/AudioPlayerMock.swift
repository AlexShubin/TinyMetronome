//
//  AudioPlayerMock.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 30.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation
@testable import MetronomeApp

final class AudioPlayerMock: AudioPlayerType, @unchecked Sendable {
    enum Calls: Equatable {
        case makeBuffer(URL)
        case play
        case stop
        case schedule(AVAudioPCMBuffer, at: Int64)
    }

    private(set) var calls: [Calls] = []

    var playheadSampleTime: Int64?

    /// Every buffer handed out by `makeBuffer`, in call order, so tests can tell them apart in `calls`.
    private(set) var madeBuffers: [AVAudioPCMBuffer] = []
    func makeBuffer(reading file: AVAudioFile) -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(
            pcmFormat: AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)!,
            frameCapacity: 1
        )!
        madeBuffers.append(buffer)
        calls.append(.makeBuffer(file.url))
        return buffer
    }

    func play() {
        calls.append(.play)
    }

    func stop() {
        calls.append(.stop)
    }

    private(set) var scheduleOnConsumed: (@Sendable () async -> Void)?
    func schedule(_ buffer: AVAudioPCMBuffer, at sampleTime: Int64, onConsumed: @escaping @Sendable () async -> Void) {
        scheduleOnConsumed = onConsumed
        calls.append(.schedule(buffer, at: sampleTime))
    }
}
