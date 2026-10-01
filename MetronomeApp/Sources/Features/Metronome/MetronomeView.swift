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
                    ForEach(metronome.beats) { beat in
                        circle(highlighted: beat.id == metronome.currentBeat)
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

    @ViewBuilder
    private func circle(highlighted: Bool) -> some View {
        let size: CGFloat = highlighted ? 35 : 25

        ZStack {
            Color.clear
                .frame(width: 40, height: 40)
            Circle()
                .fill(highlighted ? .red : .blue)
                .frame(width: size, height: size)
                .animation(.linear(duration: 0.1), value: highlighted)
        }
    }
}
