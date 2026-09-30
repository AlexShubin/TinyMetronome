//
//  MetronomeEngineTests.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 30.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation
import Testing
@testable import MetronomeApp

@Suite
struct MetronomeEngineTests {
    var playerMock: AudioPlayerMock!
    var sut: MetronomeEngineType!

    init() {
        playerMock = AudioPlayerMock()
    }

    mutating func createSut() {
        sut = MetronomeEngine(player: playerMock, sampleRate: 48000, tempo: 120, clickSample: .classic)
    }

    // MARK: - Init

    @Test
    mutating func init_loadsClickBuffers() {
        createSut()

        #expect(playerMock.calls == classicLoaded)
    }

    // MARK: - Play

    @Test
    mutating func play_startsPlayerAndSchedulesAccentedDownbeat() async {
        createSut()

        await sut.play()

        #expect(playerMock.calls == classicLoaded + [.play, .schedule(accented, at: 0)])
    }

    @Test
    mutating func play_schedulesNextBeatOnceCurrentIsConsumed() async {
        createSut()
        await sut.play()

        await playerMock.scheduleOnConsumed!()

        #expect(playerMock.calls == classicLoaded + [
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 24000),
        ])
    }

    @Test
    mutating func play_accentsFirstBeatOfEveryBar() async {
        createSut()
        await sut.play()

        for _ in 0..<BeatsPerBar.value {
            await playerMock.scheduleOnConsumed!()
        }

        #expect(playerMock.calls == classicLoaded + [
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 24000),
            .schedule(regular, at: 48000),
            .schedule(regular, at: 72000),
            .schedule(accented, at: 96000),
        ])
    }

    // MARK: - Tempo

    @Test
    mutating func setTempo_appliesToNextScheduledBeat() async {
        createSut()
        await sut.play()

        await sut.setTempo(240)
        await playerMock.scheduleOnConsumed!()

        #expect(playerMock.calls == classicLoaded + [
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 12000),
        ])
    }

    @Test
    mutating func setTempo_leavesAlreadyScheduledBeatInPlace() async {
        createSut()
        await sut.play()
        await playerMock.scheduleOnConsumed!()

        await sut.setTempo(240)
        await playerMock.scheduleOnConsumed!()

        #expect(playerMock.calls == classicLoaded + [
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 24000),
            .schedule(regular, at: 36000),
        ])
    }

    // MARK: - Click sample

    @Test
    mutating func setClickSample_reloadsBuffersAndUsesThemFromNextBeat() async {
        createSut()
        await sut.play()

        await sut.setClickSample(.digital)
        await playerMock.scheduleOnConsumed!()

        #expect(playerMock.calls == classicLoaded + [
            .play,
            .schedule(accented, at: 0),
            .makeBuffer(ClickSample.digital.accentedFile.url),
            .makeBuffer(ClickSample.digital.regularFile.url),
            .schedule(playerMock.madeBuffers[3], at: 24000),
        ])
    }

    // MARK: - Stop

    @Test
    mutating func stop_stopsPlayer() async {
        createSut()
        await sut.play()

        await sut.stop()

        #expect(playerMock.calls == classicLoaded + [.play, .schedule(accented, at: 0), .stop])
    }

    @Test
    mutating func stop_dropsConsumptionOfDiscardedBeat() async {
        createSut()
        await sut.play()
        let discarded = playerMock.scheduleOnConsumed!

        await sut.stop()
        await discarded()

        #expect(playerMock.calls == classicLoaded + [.play, .schedule(accented, at: 0), .stop])
    }

    @Test
    mutating func stop_thenPlay_dropsConsumptionFromPreviousRun() async {
        createSut()
        await sut.play()
        let previousRun = playerMock.scheduleOnConsumed!
        await sut.stop()

        await sut.play()
        await previousRun()

        #expect(playerMock.calls == classicLoaded + [
            .play,
            .schedule(accented, at: 0),
            .stop,
            .play,
            .schedule(accented, at: 0),
        ])
    }

    // MARK: - Current beat

    @Test
    mutating func currentBeat_whileStopped_isNil() async {
        playerMock.playheadSampleTime = nil
        createSut()

        #expect(await sut.currentBeat == nil)
    }

    @Test(arguments: [
        (0, 0),
        (23999, 0),
        (24000, 1),
        (30000, 1),
    ])
    mutating func currentBeat_isTheLastScheduledBeatThePlayheadPassed(playhead: Int64, expectedBeat: Int) async {
        createSut()
        await sut.play()
        await playerMock.scheduleOnConsumed!()

        playerMock.playheadSampleTime = playhead

        #expect(await sut.currentBeat == expectedBeat)
    }

    @Test
    mutating func currentBeat_afterStop_isNil() async {
        createSut()
        await sut.play()
        playerMock.playheadSampleTime = 0

        await sut.stop()

        #expect(await sut.currentBeat == nil)
    }

    // MARK: - Helpers

    private var classicLoaded: [AudioPlayerMock.Calls] {
        [
            .makeBuffer(ClickSample.classic.accentedFile.url),
            .makeBuffer(ClickSample.classic.regularFile.url),
        ]
    }

    private var accented: AVAudioPCMBuffer { playerMock.madeBuffers[0] }
    private var regular: AVAudioPCMBuffer { playerMock.madeBuffers[1] }
}
