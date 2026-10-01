//
//  ClickSample.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 12.04.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

enum ClickSample: String, Sendable, Equatable, CaseIterable, Identifiable, CustomStringConvertible {
    case classic
    case digital
    case logicStyle

    var id: String { rawValue }

    var description: String {
        switch self {
        case .classic: "Classic"
        case .digital: "Digital"
        case .logicStyle: "Logic Style"
        }
    }
}
