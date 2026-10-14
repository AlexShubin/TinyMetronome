//
//  MetronomeSettings.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 13.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

struct MetronomeSettings: Equatable, Codable {
    let tempo: Int
    let clickSample: ClickSample
    let beats: [Beat]
    let volume: Double
}
