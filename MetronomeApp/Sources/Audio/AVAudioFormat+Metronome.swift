//
//  AVAudioFormat+Metronome.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 01.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation

extension AVAudioFormat {
    /// The one format the app plays: 48 kHz, mono. Every click file is exported in it, and the player graph runs in it.
    static let metronome = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)!
}
