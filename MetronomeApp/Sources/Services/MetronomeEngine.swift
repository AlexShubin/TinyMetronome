//
//  MetronomeEngine.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import AVFoundation

protocol MetronomeEngineType: Sendable {
    /// Takes effect on the next beat that hasn't been scheduled yet.
    func setTempo(_ bpm: Double) async
    func setClickSample(_ clickSample: ClickSample) async

    func play() async
    func stop() async

    /// Zero-based index of the beat under the playhead, `nil` while stopped.
    var currentBeat: Int? { get async }
}

private struct ScheduledBeat {
    let index: Int
    let sampleTime: Int64
}

private struct ClickBuffers {
    let accented: AVAudioPCMBuffer
    let regular: AVAudioPCMBuffer

    init(clickSample: ClickSample, player: AudioPlayerType) {
        accented = player.makeBuffer(reading: clickSample.accentedFile)
        regular = player.makeBuffer(reading: clickSample.regularFile)
    }

    func buffer(forBeat index: Int) -> AVAudioPCMBuffer {
        index == 0 ? accented : regular
    }
}

actor MetronomeEngine: MetronomeEngineType {
    private let player: AudioPlayerType
    private let sampleRate: Double
    private var tempo: Double
    private var clickBuffers: ClickBuffers
    private var scheduledBeats: [ScheduledBeat] = []
    private var playbackRun = UUID()

    init(player: AudioPlayerType, sampleRate: Double, tempo: Double, clickSample: ClickSample) {
        self.player = player
        self.sampleRate = sampleRate
        self.tempo = tempo
        clickBuffers = ClickBuffers(clickSample: clickSample, player: player)
    }

    func setTempo(_ bpm: Double) {
        tempo = bpm
    }

    func setClickSample(_ clickSample: ClickSample) {
        clickBuffers = ClickBuffers(clickSample: clickSample, player: player)
    }

    func play() {
        playbackRun = UUID()
        player.play()
        schedule(ScheduledBeat(index: 0, sampleTime: 0))
    }

    func stop() {
        scheduledBeats.removeAll()
        player.stop()
    }

    var currentBeat: Int? {
        guard let playhead = player.playheadSampleTime else { return nil }
        return scheduledBeats.last { $0.sampleTime <= playhead }?.index
    }

    private var beatLength: Int64 {
        Int64(sampleRate * 60 / tempo)
    }

    private func schedule(_ beat: ScheduledBeat) {
        scheduledBeats = scheduledBeats.suffix(1) + [beat]

        let run = playbackRun
        player.schedule(clickBuffers.buffer(forBeat: beat.index), at: beat.sampleTime) { [weak self] in
            await self?.scheduleNextBeat(ifStillIn: run)
        }
    }

    private func scheduleNextBeat(ifStillIn run: UUID) {
        guard run == playbackRun, let last = scheduledBeats.last else { return }
        schedule(ScheduledBeat(
            index: (last.index + 1) % BeatsPerBar.value,
            sampleTime: last.sampleTime + beatLength
        ))
    }
}
