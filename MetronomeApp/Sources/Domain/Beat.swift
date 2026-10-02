//
//  Beat.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 01.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

struct Beat: Identifiable, Equatable {
    enum Click: Equatable {
        case accented
        case regular
    }

    let id: Int
    var click: Click
}

extension Beat {
    /// Four beats, accent on the first.
    static let standardBar: [Beat] = [
        Beat(id: 0, click: .accented),
        Beat(id: 1, click: .regular),
        Beat(id: 2, click: .regular),
        Beat(id: 3, click: .regular),
    ]
}
