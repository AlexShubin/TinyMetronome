//
//  MetronomeView.swift
//  TinyMetronome
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
                        .pointerStyle(.link)
                    }
                }
                .frame(height: 80)
            }

            HStack(spacing: 24) {
                DraggableTempoControl(tempo: $metronome.tempo,
                                      range: Tempo.range)

                Button(action: metronome.togglePlayback) {
                    Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
                        .font(.largeTitle)
                }
                .frame(width: 60)
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
        ZStack {
            Color.clear
                .frame(width: 40, height: 40)
            Circle()
                .fill(indicator.fill)
                .frame(width: 25, height: 25)
                .shadow(color: .gray, radius: 4)
                .animation(.linear(duration: 0.1), value: indicator.highlighted)
        }
    }
}

private struct BeatIndicator: Identifiable {
    let beat: Beat
    let highlighted: Bool

    var id: Int { beat.id }

    var fill: Color {
        let color: Color = switch beat.click {
        case .accented: .beatAccent
        case .regular: .beatRegular
        case .silent: .beatSilent
        }
        return color.opacity(highlighted ? 0.9 : 0.6)
    }
}
