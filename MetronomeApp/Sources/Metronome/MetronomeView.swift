//
//  MetronomeView.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 07.02.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import SwiftUI

struct MetronomeView: View {
    @State var metronome: Metronome

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            TimelineView(.animation(paused: !metronome.isPlaying)) { _ in
                HStack(spacing: 40) {
                    ForEach(beatIndicators) { indicator in
                        Button {
                            metronome.cycleClick(ofBeat: indicator.id)
                        } label: {
                            circle(indicator)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 80)
            }

            HStack(spacing: 24) {
                DraggableTempoControl(tempo: $metronome.tempo,
                                      range: 40...240)

                Button(action: metronome.togglePlayback) {
                    Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
                        .font(.largeTitle)
                }
            }

            ClickSamplePicker(selection: $metronome.clickSample)
        }
        .padding()
        .frame(minWidth: 360)
    }

    private var beatIndicators: [BeatIndicator] {
        let current = metronome.currentBeat
        return metronome.beats.map { BeatIndicator(beat: $0, highlighted: $0.id == current) }
    }

    @ViewBuilder
    private func circle(_ indicator: BeatIndicator) -> some View {
        let size: CGFloat = indicator.highlighted ? 35 : 25

        ZStack {
            Color.clear
                .frame(width: 40, height: 40)
            Circle()
                .fill(indicator.fill)
                .frame(width: size, height: size)
                .animation(.linear(duration: 0.1), value: indicator.highlighted)
        }
    }
}

private struct BeatIndicator: Identifiable {
    let beat: Beat
    let highlighted: Bool

    var id: Int { beat.id }

    var fill: AnyShapeStyle {
        switch beat.click {
        case .accented: AnyShapeStyle(.blue)
        case .regular: AnyShapeStyle(.blue.secondary)
        }
    }
}
