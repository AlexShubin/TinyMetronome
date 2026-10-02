//
//  ClickBuffersFactoryTests.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 02.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation
import Testing
@testable import MetronomeApp

/// Pins the promises the bundled click files make to the scheduler.
@Suite
struct ClickBuffersFactoryTests {
    var sut: ClickBuffersFactoryType!

    mutating func createSut() {
        sut = ClickBuffersFactory()
    }

    @Test(arguments: ClickSample.allCases)
    mutating func makeBuffers_readsBothClicksInTheAppFormat(clickSample: ClickSample) {
        createSut()

        let buffers = sut.makeBuffers(for: clickSample)

        #expect(buffers.accented.pcm.format == .metronome)
        #expect(buffers.regular.pcm.format == .metronome)
        #expect(buffers.accented.pcm.frameLength > 0)
        #expect(buffers.regular.pcm.frameLength > 0)
    }

    @Test(arguments: ClickSample.allCases)
    mutating func makeBuffers_clicksAreShorterThanTheShortestBeat(clickSample: ClickSample) {
        createSut()

        let buffers = sut.makeBuffers(for: clickSample)

        #expect(buffers.accented.pcm.frameLength < shortestBeatLength)
        #expect(buffers.regular.pcm.frameLength < shortestBeatLength)
    }

    // MARK: - Helpers

    private var shortestBeatLength: AVAudioFrameCount {
        AVAudioFrameCount(AVAudioFormat.metronome.sampleRate * 60 / Double(Tempo.range.upperBound))
    }
}
