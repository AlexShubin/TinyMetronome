//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Foundation
import Observation

@MainActor
protocol MetronomeViewModelType: Observable {
    var tempo: Int { get set }
    var clickSample: ClickSample { get set }
    var playButtonState: PlayButtonState { get }
    var beats: [Beat] { get }

    @discardableResult func playStopTapped() -> Task<Void, Never>
    @discardableResult func tick() -> Task<Void, Never>
}

@MainActor @Observable
class MetronomeViewModel: MetronomeViewModelType {
    var tempo: Int {
        didSet {
            Task { await engine.setTempo(Double(tempo)) }
        }
    }

    var clickSample: ClickSample {
        didSet {
            Task { await engine.setClickSample(clickSample) }
        }
    }

    var playButtonState: PlayButtonState {
        isPlaying ? .stop : .play
    }

    var beats: [Beat] {
        .bar(highlighting: currentBeat)
    }

    private var isPlaying = false
    private var currentBeat: Int?

    @ObservationIgnored private let engine: MetronomeEngineType

    init(engine: MetronomeEngineType, tempo: Int, clickSample: ClickSample) {
        self.engine = engine
        self.tempo = tempo
        self.clickSample = clickSample
    }

    @discardableResult
    func playStopTapped() -> Task<Void, Never> {
        if isPlaying {
            isPlaying = false
            currentBeat = nil
            return Task { await engine.stop() }
        } else {
            isPlaying = true
            return Task { await engine.play() }
        }
    }

    @discardableResult
    func tick() -> Task<Void, Never> {
        Task {
            guard isPlaying else { return }
            let beat = await engine.currentBeat
            guard isPlaying, beat != currentBeat else { return }
            currentBeat = beat
        }
    }
}

enum PlayButtonState: Equatable {
    case play, stop
}

struct Beat: Identifiable, Equatable {
    let id: Int
    let highlighted: Bool
}

private extension [Beat] {
    static func bar(highlighting beat: Int?) -> [Beat] {
        (0..<BeatsPerBar.value).map { Beat(id: $0, highlighted: $0 == beat) }
    }
}
