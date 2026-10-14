//
//  SettingsStore.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 13.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Foundation

protocol SettingsStoreType: Sendable {
    /// `nil` when nothing is stored or it no longer decodes.
    var settings: MetronomeSettings? { get }
    func save(_ settings: MetronomeSettings)
}

struct SettingsStore: SettingsStoreType {
    private static let key = "metronome_settings"

    var settings: MetronomeSettings? {
        guard let data = UserDefaults.standard.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(MetronomeSettings.self, from: data)
    }

    func save(_ settings: MetronomeSettings) {
        UserDefaults.standard.set(try! JSONEncoder().encode(settings), forKey: Self.key)
    }
}
