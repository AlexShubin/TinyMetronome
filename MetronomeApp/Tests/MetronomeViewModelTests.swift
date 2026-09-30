//
//  MetronomeViewModelTests.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 25.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Testing
@testable import MetronomeApp

@Suite @MainActor
struct MetronomeViewModelTests {
    var engineMock: MetronomeEngineMock!
    var sut: MetronomeViewModelType!

    init() {
        engineMock = MetronomeEngineMock()
    }

    mutating func createSut() {
        sut = MetronomeViewModel(engine: engineMock, tempo: 120, clickSample: .classic)
    }

    // MARK: - Initial state

    @Test
    mutating func initialState() {
        createSut()

        #expect(sut.tempo == 120)
        #expect(sut.clickSample == .classic)
        #expect(sut.playButtonState == .play)
        #expect(sut.beats == .bar(highlighting: nil))
        #expect(engineMock.calls.isEmpty)
    }

    // MARK: - Play and stop

    @Test
    mutating func playStopTapped_whenStopped_startsPlayback() async throws {
        createSut()

        sut.playStopTapped()
        try await settle()

        #expect(sut.playButtonState == .stop)
        #expect(engineMock.calls == [.play])
    }

    @Test
    mutating func playStopTapped_whenPlaying_stopsEngine() async throws {
        createSut()
        sut.playStopTapped()

        sut.playStopTapped()
        try await settle()

        #expect(sut.playButtonState == .play)
        #expect(engineMock.calls == [.play, .stop])
    }

    @Test
    mutating func playStopTapped_whenPlaying_clearsHighlight() async throws {
        engineMock.currentBeat = 2
        createSut()
        sut.playStopTapped()
        sut.tick()
        try await settle()

        sut.playStopTapped()
        try await settle()

        #expect(sut.beats == .bar(highlighting: nil))
    }

    // MARK: - Tempo

    @Test
    mutating func tempo_set_forwardsToEngine() async throws {
        createSut()

        sut.tempo = 180
        try await settle()

        #expect(sut.tempo == 180)
        #expect(engineMock.calls == [.setTempo(180)])
    }

    // MARK: - Click sample

    @Test
    mutating func clickSample_set_forwardsToEngine() async throws {
        createSut()

        sut.clickSample = .digital
        try await settle()

        #expect(sut.clickSample == .digital)
        #expect(engineMock.calls == [.setClickSample(.digital)])
    }

    // MARK: - Tick

    @Test(arguments: [nil, 0, 1, 2, 3])
    mutating func tick_highlightsEngineCurrentBeat(beat: Int?) async throws {
        engineMock.currentBeat = beat
        createSut()

        sut.tick()
        try await settle()

        #expect(sut.beats == .bar(highlighting: beat))
    }

    // MARK: - Helpers

    private func settle() async throws {
        try await Task.sleep(for: .milliseconds(20))
    }
}

private extension [Beat] {
    static func bar(highlighting beat: Int?) -> [Beat] {
        (0..<BeatsPerBar.value).map { Beat(id: $0, highlighted: $0 == beat) }
    }
}
