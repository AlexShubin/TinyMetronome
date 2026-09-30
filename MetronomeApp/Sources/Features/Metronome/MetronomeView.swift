//
//  MetronomeView.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 07.02.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import SwiftUI

struct MetronomeView: View {
    @State var presenter: MetronomePresenter

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            TimelineView(.animation(paused: presenter.viewModel.beatsPaused)) { _ in
                HStack(spacing: 40) {
                    ForEach(presenter.viewModel.beats) { beat in
                        circle(beat)
                    }
                }
                .frame(height: 80)
            }

            HStack(spacing: 24) {
                DraggableTempoControl(tempo: Binding(get: { presenter.viewModel.tempo },
                                                     set: presenter.setTempo),
                                      range: 40...240)

                Button(action: presenter.togglePlayback) {
                    Image(systemName: presenter.viewModel.playButton.imageName)
                        .font(.largeTitle)
                }
            }

            ClickSamplePicker(selection: Binding(get: { presenter.viewModel.clickSample },
                                                 set: presenter.setClickSample))
        }
        .padding()
        .frame(minWidth: 360)
    }

    @ViewBuilder
    private func circle(_ beat: MetronomeViewModel.Beat) -> some View {
        let size: CGFloat = beat.highlighted ? 35 : 25

        ZStack {
            Color.clear
                .frame(width: 40, height: 40)
            Circle()
                .fill(beat.highlighted ? .red : .blue)
                .frame(width: size, height: size)
                .animation(.linear(duration: 0.1), value: beat.highlighted)
        }
    }
}

private extension MetronomeViewModel.PlayButton {
    var imageName: String {
        switch self {
        case .play: "play.fill"
        case .stop: "stop.fill"
        }
    }
}
