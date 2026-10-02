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
    mutating func makeBuffers_readsAllClicksInTheAppFormat(clickSample: ClickSample) {
        createSut()

        let buffers = sut.makeBuffers(for: clickSample)

        for buffer in buffers.all {
            #expect(buffer.pcm.format == .metronome)
            #expect(buffer.pcm.frameLength > 0)
        }
    }

    @Test(arguments: ClickSample.allCases)
    mutating func makeBuffers_clicksAreShorterThanTheShortestBeat(clickSample: ClickSample) {
        createSut()

        let buffers = sut.makeBuffers(for: clickSample)

        for buffer in buffers.all {
            #expect(buffer.pcm.frameLength < shortestBeatLength)
        }
    }

    @Test(arguments: ClickSample.allCases)
    mutating func makeBuffers_silentClickIsAllZeros(clickSample: ClickSample) {
        createSut()

        let silent = sut.makeBuffers(for: clickSample).silent.pcm

        let samples = UnsafeBufferPointer(start: silent.floatChannelData![0], count: Int(silent.frameLength))
        #expect(samples.allSatisfy { $0 == 0 })
    }

    // MARK: - Helpers

    private var shortestBeatLength: AVAudioFrameCount {
        AVAudioFrameCount(AVAudioFormat.metronome.sampleRate * 60 / Double(Tempo.range.upperBound))
    }
}

private extension ClickBuffers {
    var all: [ClickBuffer] { [accented, regular, silent] }
}
