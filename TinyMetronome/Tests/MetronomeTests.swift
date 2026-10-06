//
//  MetronomeTests.swift
//  TinyMetronomeTests
//
//  Created by Alex Shubin on 02.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Testing
@testable import TinyMetronome

@Suite @MainActor
struct MetronomeTests {
    var playerSpy: AudioPlayerSpy!
    var clickBuffersFactorySpy: ClickBuffersFactorySpy!
    var sut: Metronome!

    init() {
        playerSpy = AudioPlayerSpy()
        clickBuffersFactorySpy = ClickBuffersFactorySpy()
    }

    mutating func createSut() {
        sut = Metronome(
            player: playerSpy,
            clickBuffersFactory: clickBuffersFactorySpy,
            tempo: 120,
            clickSample: .classic,
            beats: bar,
            volume: 1
        )
    }

    // MARK: - Init

    @Test
    mutating func init_loadsBuffersForTheInitialClickSample() {
        createSut()

        #expect(clickBuffersFactorySpy.calls == [.makeBuffers(.classic)])
    }

    @Test
    mutating func init_appliesTheVolumeToThePlayer() {
        createSut()

        #expect(playerSpy.calls == [.setVolume(1)])
    }

    @Test
    mutating func init_isStopped() {
        createSut()

        #expect(sut.tempo == 120)
        #expect(sut.clickSample == .classic)
        #expect(sut.beats == bar)
        #expect(sut.volume == 1)
        #expect(!sut.isPlaying)
        #expect(sut.currentBeat == nil)
    }

    // MARK: - Playback

    @Test
    mutating func togglePlayback_whenStopped_startsPlayerAndSchedulesTheDownbeat() {
        createSut()

        sut.togglePlayback()

        #expect(sut.isPlaying)
        #expect(playerSpy.calls == [.setVolume(1), .play, .schedule(accented, at: 0)])
    }

    @Test
    mutating func consumedBeat_schedulesTheNextOne() async {
        createSut()
        sut.togglePlayback()

        await playerSpy.scheduleOnConsumed!()

        #expect(playerSpy.calls == [
            .setVolume(1),
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 24000),
        ])
    }

    @Test
    mutating func consumedBeat_wrapsToTheDownbeatAfterTheBar() async {
        createSut()
        sut.togglePlayback()

        for _ in bar.indices {
            await playerSpy.scheduleOnConsumed!()
        }

        #expect(playerSpy.calls == [
            .setVolume(1),
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 24000),
            .schedule(regular, at: 48000),
            .schedule(regular, at: 72000),
            .schedule(accented, at: 96000),
        ])
    }

    @Test
    mutating func togglePlayback_whenPlaying_stopsPlayer() {
        createSut()
        sut.togglePlayback()

        sut.togglePlayback()

        #expect(!sut.isPlaying)
        #expect(playerSpy.calls == [.setVolume(1), .play, .schedule(accented, at: 0), .stop])
    }

    @Test
    mutating func togglePlayback_whenPlaying_dropsConsumptionOfTheDiscardedBeat() async {
        createSut()
        sut.togglePlayback()
        let discarded = playerSpy.scheduleOnConsumed!

        sut.togglePlayback()
        await discarded()

        #expect(playerSpy.calls == [.setVolume(1), .play, .schedule(accented, at: 0), .stop])
    }

    @Test
    mutating func togglePlayback_stopThenPlay_dropsConsumptionFromThePreviousRun() async {
        createSut()
        sut.togglePlayback()
        let previousRun = playerSpy.scheduleOnConsumed!
        sut.togglePlayback()

        sut.togglePlayback()
        await previousRun()

        #expect(playerSpy.calls == [
            .setVolume(1),
            .play,
            .schedule(accented, at: 0),
            .stop,
            .play,
            .schedule(accented, at: 0),
        ])
    }

    // MARK: - Tempo

    @Test
    mutating func tempo_set_appliesToTheNextScheduledBeat() async {
        createSut()
        sut.togglePlayback()

        sut.tempo = 240
        await playerSpy.scheduleOnConsumed!()

        #expect(playerSpy.calls == [
            .setVolume(1),
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 12000),
        ])
    }

    @Test
    mutating func tempo_set_leavesTheAlreadyScheduledBeatInPlace() async {
        createSut()
        sut.togglePlayback()
        await playerSpy.scheduleOnConsumed!()

        sut.tempo = 240
        await playerSpy.scheduleOnConsumed!()

        #expect(playerSpy.calls == [
            .setVolume(1),
            .play,
            .schedule(accented, at: 0),
            .schedule(regular, at: 24000),
            .schedule(regular, at: 36000),
        ])
    }

    // MARK: - Volume

    @Test
    mutating func volume_set_forwardsToThePlayer() {
        createSut()

        sut.volume = 0.5

        #expect(sut.volume == 0.5)
        #expect(playerSpy.calls == [.setVolume(1), .setVolume(0.5)])
    }

    // MARK: - Click sample

    @Test
    mutating func clickSample_set_reloadsBuffers() {
        createSut()

        sut.clickSample = .digital

        #expect(sut.clickSample == .digital)
        #expect(clickBuffersFactorySpy.calls == [.makeBuffers(.classic), .makeBuffers(.digital)])
    }

    @Test
    mutating func clickSample_set_usesTheNewBuffersFromTheNextBeat() async {
        createSut()
        sut.togglePlayback()
        let classic = clickBuffersFactorySpy.makeBuffersResult
        let digital = ClickBuffers(accented: .fake(), regular: .fake(), silent: .fake())

        clickBuffersFactorySpy.makeBuffersResult = digital
        sut.clickSample = .digital
        await playerSpy.scheduleOnConsumed!()

        #expect(playerSpy.calls == [
            .setVolume(1),
            .play,
            .schedule(classic.accented, at: 0),
            .schedule(digital.regular, at: 24000),
        ])
    }

    // MARK: - Beats

    @Test
    mutating func cycleClick_ofAccentedBeat_makesItRegular() {
        createSut()

        sut.cycleClick(ofBeat: 0)

        #expect(sut.beats == [
            Beat(id: 0, click: .regular),
            Beat(id: 1, click: .regular),
            Beat(id: 2, click: .regular),
            Beat(id: 3, click: .regular),
        ])
    }

    @Test
    mutating func cycleClick_ofRegularBeat_makesItSilent() {
        createSut()

        sut.cycleClick(ofBeat: 2)

        #expect(sut.beats == [
            Beat(id: 0, click: .accented),
            Beat(id: 1, click: .regular),
            Beat(id: 2, click: .silent),
            Beat(id: 3, click: .regular),
        ])
    }

    @Test
    mutating func cycleClick_ofSilentBeat_makesItAccented() {
        createSut()
        sut.cycleClick(ofBeat: 2)

        sut.cycleClick(ofBeat: 2)

        #expect(sut.beats == [
            Beat(id: 0, click: .accented),
            Beat(id: 1, click: .regular),
            Beat(id: 2, click: .accented),
            Beat(id: 3, click: .regular),
        ])
    }

    @Test
    mutating func cycleClick_appliesWhenTheBeatIsScheduledNext() async {
        createSut()
        sut.togglePlayback()

        sut.cycleClick(ofBeat: 1)
        await playerSpy.scheduleOnConsumed!()

        #expect(playerSpy.calls == [
            .setVolume(1),
            .play,
            .schedule(accented, at: 0),
            .schedule(silent, at: 24000),
        ])
    }

    // MARK: - Current beat

    @Test
    mutating func currentBeat_whileStopped_isNil() {
        playerSpy.playheadSampleTime = 24000
        createSut()

        #expect(sut.currentBeat == nil)
    }

    @Test(arguments: [
        (0, 0),
        (23999, 0),
        (24000, 1),
        (30000, 1),
    ])
    mutating func currentBeat_isTheLastScheduledBeatThePlayheadPassed(playhead: Int64, expectedBeat: Int) async {
        createSut()
        sut.togglePlayback()
        await playerSpy.scheduleOnConsumed!()

        playerSpy.playheadSampleTime = playhead

        #expect(sut.currentBeat == expectedBeat)
    }

    @Test
    mutating func currentBeat_afterStop_isNil() {
        createSut()
        sut.togglePlayback()
        playerSpy.playheadSampleTime = 0

        sut.togglePlayback()

        #expect(sut.currentBeat == nil)
    }

    // MARK: - Helpers

    private let bar = [
        Beat(id: 0, click: .accented),
        Beat(id: 1, click: .regular),
        Beat(id: 2, click: .regular),
        Beat(id: 3, click: .regular),
    ]

    private var accented: ClickBuffer { clickBuffersFactorySpy.makeBuffersResult.accented }
    private var regular: ClickBuffer { clickBuffersFactorySpy.makeBuffersResult.regular }
    private var silent: ClickBuffer { clickBuffersFactorySpy.makeBuffersResult.silent }
}
