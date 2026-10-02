//
//  AudioPlayerSpy.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 30.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

@testable import MetronomeApp

final class AudioPlayerSpy: AudioPlayerType, @unchecked Sendable {
    enum Calls: Equatable {
        case play
        case stop
        case schedule(ClickBuffer, at: Int64)
    }

    private(set) var calls: [Calls] = []

    var sampleRate: Double = 48000

    var playheadSampleTime: Int64?

    func play() {
        calls.append(.play)
    }

    func stop() {
        calls.append(.stop)
    }

    private(set) var scheduleOnConsumed: (@Sendable () async -> Void)?
    func schedule(_ buffer: ClickBuffer, at sampleTime: Int64, onConsumed: @escaping @Sendable () async -> Void) {
        scheduleOnConsumed = onConsumed
        calls.append(.schedule(buffer, at: sampleTime))
    }
}
