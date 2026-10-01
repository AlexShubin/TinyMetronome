//
//  Metronome.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 30.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation
import Observation

private struct ScheduledBeat {
    let index: Int
    let sampleTime: Int64
}

@MainActor @Observable
final class Metronome {
    /// Beats per minute. Takes effect on the next beat that hasn't been scheduled yet.
    var tempo: Int

    var clickSample: ClickSample {
        didSet { clickBuffers = clickBuffersFactory.makeBuffers(for: clickSample) }
    }

    var beats: [Beat]

    private(set) var isPlaying = false

    /// Zero-based index of the beat under the playhead, `nil` while stopped.
    var currentBeat: Int? {
        guard let playhead = player.playheadSampleTime else { return nil }
        return scheduledBeats.last { $0.sampleTime <= playhead }?.index
    }

    @ObservationIgnored private let player: AudioPlayerType
    @ObservationIgnored private let clickBuffersFactory: ClickBuffersFactoryType
    @ObservationIgnored private var clickBuffers: ClickBuffers
    @ObservationIgnored private var scheduledBeats: [ScheduledBeat] = []
    @ObservationIgnored private var playbackRun = UUID()

    init(
        player: AudioPlayerType,
        clickBuffersFactory: ClickBuffersFactoryType,
        tempo: Int,
        clickSample: ClickSample,
        beats: [Beat]
    ) {
        self.player = player
        self.clickBuffersFactory = clickBuffersFactory
        self.tempo = tempo
        self.clickSample = clickSample
        self.beats = beats
        clickBuffers = clickBuffersFactory.makeBuffers(for: clickSample)
    }

    func togglePlayback() {
        if isPlaying {
            stop()
        } else {
            play()
        }
    }

    /// Advances the beat to its next click; takes effect the next time that beat is scheduled.
    func cycleClick(ofBeat id: Beat.ID) {
        let index = beats.firstIndex { $0.id == id }!
        beats[index].click = beats[index].click.next
    }

    private func play() {
        isPlaying = true
        playbackRun = UUID()
        player.play()
        schedule(ScheduledBeat(index: 0, sampleTime: 0))
    }

    private func stop() {
        isPlaying = false
        scheduledBeats.removeAll()
        player.stop()
    }

    private var beatLength: Int64 {
        Int64(player.sampleRate * 60 / Double(tempo))
    }

    private func schedule(_ beat: ScheduledBeat) {
        scheduledBeats = scheduledBeats.suffix(1) + [beat]

        let run = playbackRun
        player.schedule(clickBuffers.buffer(for: beats[beat.index].click), at: beat.sampleTime) { [weak self] in
            await self?.scheduleNextBeat(ifStillIn: run)
        }
    }

    private func scheduleNextBeat(ifStillIn run: UUID) {
        guard run == playbackRun, let last = scheduledBeats.last else { return }
        schedule(ScheduledBeat(
            index: (last.index + 1) % beats.count,
            sampleTime: last.sampleTime + beatLength
        ))
    }
}

private extension Beat.Click {
    var next: Beat.Click {
        switch self {
        case .accented: .regular
        case .regular: .accented
        }
    }
}
