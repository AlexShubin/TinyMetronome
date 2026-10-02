//
//  ClickBuffersFactorySpy.swift
//  TinyMetronomeTests
//
//  Created by Alex Shubin on 02.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

@testable import TinyMetronome

final class ClickBuffersFactorySpy: ClickBuffersFactoryType, @unchecked Sendable {
    enum Calls: Equatable {
        case makeBuffers(ClickSample)
    }

    private(set) var calls: [Calls] = []

    var makeBuffersResult = ClickBuffers(accented: .fake(), regular: .fake(), silent: .fake())
    func makeBuffers(for clickSample: ClickSample) -> ClickBuffers {
        calls.append(.makeBuffers(clickSample))
        return makeBuffersResult
    }
}
