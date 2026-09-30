//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 30.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

/// What the screen shows: plain values, no behavior.
struct MetronomeViewModel: Equatable {
    struct Beat: Identifiable, Equatable {
        let id: Int
        let highlighted: Bool
    }

    enum PlayButton: Equatable {
        case play, stop
    }

    let beats: [Beat]
    let beatsPaused: Bool
    let playButton: PlayButton
    let tempo: Int
    let clickSample: ClickSample
}


