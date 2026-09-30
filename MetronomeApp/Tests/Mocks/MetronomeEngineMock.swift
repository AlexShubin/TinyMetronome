//
//  MetronomeEngineMock.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 21.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

@testable import MetronomeApp

final class MetronomeEngineMock: MetronomeEngineType, @unchecked Sendable {
    enum Calls: Equatable {
        case setTempo(Double)
        case setClickSample(ClickSample)
        case play
        case stop
    }

    private(set) var calls: [Calls] = []

    func setTempo(_ bpm: Double) {
        calls.append(.setTempo(bpm))
    }

    func setClickSample(_ clickSample: ClickSample) {
        calls.append(.setClickSample(clickSample))
    }

    func play() {
        calls.append(.play)
    }

    func stop() {
        calls.append(.stop)
    }

    var currentBeat: Int?
}
