//
//  SettingsStoreSpy.swift
//  TinyMetronomeTests
//
//  Created by Alex Shubin on 13.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

@testable import TinyMetronome

final class SettingsStoreSpy: SettingsStoreType, @unchecked Sendable {
    enum Calls: Equatable {
        case save(MetronomeSettings)
    }

    private(set) var calls: [Calls] = []

    var settings: MetronomeSettings?

    func save(_ settings: MetronomeSettings) {
        calls.append(.save(settings))
    }
}
