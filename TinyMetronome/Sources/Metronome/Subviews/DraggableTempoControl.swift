//
//  DraggableTempoControl.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct DraggableTempoControl: View {
    @Binding var tempo: Int
    let range: ClosedRange<Int>

    @State private var dragStartTempo: Int?
    @State private var scrollRemainder: CGFloat = 0

    private let pointsPerStep: CGFloat = 20

    var body: some View {
        VStack {
            Text("BPM")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                ZStack {
                    Text("\(range.upperBound)")
                        .hidden()
                    Text("\(tempo)")
                        .contentTransition(.numericText())
                }
                .font(.system(size: 48, weight: .medium, design: .rounded))
                .monospacedDigit()

                VStack(spacing: 2) {
                    Image(systemName: "arrowtriangle.up.fill")
                    Image(systemName: "arrowtriangle.down.fill")
                }
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            .pointerStyle(.rowResize(directions: .all))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if dragStartTempo == nil {
                            dragStartTempo = tempo
                        }
                        let delta = Int(-value.translation.height / pointsPerStep)
                        setTempo((dragStartTempo ?? tempo) + delta)
                    }
                    .onEnded { _ in
                        dragStartTempo = nil
                    }
            )
            .onScrollWheel(pointsPerNotch: pointsPerStep) { points in
                scrollRemainder += points
                let steps = Int(scrollRemainder / pointsPerStep)
                scrollRemainder.formTruncatingRemainder(dividingBy: pointsPerStep)
                setTempo(tempo + steps)
            }
        }
    }

    private func setTempo(_ newTempo: Int) {
        let clampedTempo = min(max(newTempo, range.lowerBound), range.upperBound)
        if clampedTempo != tempo {
            withAnimation(.snappy(duration: 0.15)) {
                tempo = clampedTempo
            }
        }
    }
}
