//
//  MetronomePresenter.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 30.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

/// Projects `Metronome` into what the view needs. Stores nothing: every read goes to the model.
@MainActor
struct MetronomePresenter {
    private let metronome: MetronomeType

    init(metronome: MetronomeType) {
        self.metronome = metronome
    }

    var viewModel: MetronomeViewModel {
        let current = metronome.currentBeat
        return MetronomeViewModel(
            beats: (0..<BeatsPerBar.value).map { .init(id: $0, highlighted: $0 == current) },
            beatsPaused: !metronome.isPlaying,
            playButton: metronome.isPlaying ? .stop : .play,
            tempo: metronome.tempo,
            clickSample: metronome.clickSample
        )
    }

    func setTempo(_ tempo: Int) {
        metronome.tempo = tempo
    }

    func setClickSample(_ clickSample: ClickSample) {
        metronome.clickSample = clickSample
    }

    func togglePlayback() {
        metronome.togglePlayback()
    }
}
