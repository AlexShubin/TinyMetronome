//
//  Dependencies.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation
import SwiftUI

struct Dependencies {
    static let live = Dependencies()

    @MainActor func makeMetronomeViewModel() -> MetronomeViewModelType {
        let format = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)!
        let tempo = 120
        let clickSample = ClickSample.classic
        return MetronomeViewModel(
            engine: MetronomeEngine(
                player: AudioPlayer(format: format),
                sampleRate: format.sampleRate,
                tempo: Double(tempo),
                clickSample: clickSample
            ),
            tempo: tempo,
            clickSample: clickSample
        )
    }
}

// MARK: - Environment

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue = Dependencies.live
}

extension EnvironmentValues {
    var dependencies: Dependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}
