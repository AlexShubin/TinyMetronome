//
//  KnobControl.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 03.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

/// A rotary knob for a 0...1 value, turned by dragging up and down. Label and value sit above the dial.
struct KnobControl: View {
    @Binding var value: Double
    let label: String

    @State private var dragStartValue: Double?

    private let pointsPerFullRange: CGFloat = 200
    private let sweep = Angle.degrees(270)
    private let trackStart = Angle.degrees(135)
    private let dialSize: CGFloat = 72

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value, format: .percent.precision(.fractionLength(0)))
                .font(.title2.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            dial
                .frame(width: dialSize, height: dialSize)
                .padding(.top, 6)
        }
        .pointerStyle(.rowResize(directions: .all))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    if dragStartValue == nil {
                        dragStartValue = value
                    }
                    let delta = -drag.translation.height / pointsPerFullRange
                    value = min(max((dragStartValue ?? value) + delta, 0), 1)
                }
                .onEnded { _ in
                    dragStartValue = nil
                }
        )
    }

    private var dial: some View {
        ZStack {
            track(to: 1)
                .stroke(.fill.tertiary, style: trackStyle)
            track(to: value)
                .stroke(.primary, style: trackStyle)

            Circle()
                .fill(.fill.secondary)
                .padding(9)
                .shadow(color: .black.opacity(0.3), radius: 3, y: 1)

            Capsule()
                .fill(.primary)
                .frame(width: 3, height: 16)
                .offset(y: -14)
                .rotationEffect(pointerAngle)
        }
    }

    private func track(to fraction: Double) -> some Shape {
        Circle()
            .trim(from: 0, to: fraction * sweep.degrees / 360)
            .rotation(trackStart)
    }

    private var trackStyle: StrokeStyle {
        StrokeStyle(lineWidth: 5, lineCap: .round)
    }

    /// The pointer is drawn at 12 o'clock; the track starts 225° clockwise from there.
    private var pointerAngle: Angle {
        .degrees(225) + sweep * value
    }
}

#Preview {
    @Previewable @State var value = 1.0

    KnobControl(
        value: $value,
        label: "Volume"
    )
        .padding(32)
}
