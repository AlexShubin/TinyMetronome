//
//  TinyMetronomeApp.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 07.02.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import SwiftUI

@main
struct TinyMetronomeApp: App {
    var body: some Scene {
        Window("Tiny Metronome", id: "metronome") {
            MetronomeView(metronome: Metronome(
                player: AudioPlayer(),
                clickBuffersFactory: ClickBuffersFactory(),
                tempo: 120,
                clickSample: .classic,
                beats: Beat.standardBar
            ))
        }
        .windowResizability(.contentSize)
    }
}
