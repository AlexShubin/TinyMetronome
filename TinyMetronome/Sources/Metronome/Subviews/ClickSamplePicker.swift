//
//  ClickSamplePicker.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 14.04.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

/// A popup-style button whose list opens in a popover: unlike a menu, a popover doesn't block the window from redrawing.
struct ClickSamplePicker: View {
    @Binding var selection: ClickSample

    @State private var isPresented = false

    var body: some View {
        VStack {
            Text("Click Sample")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                isPresented.toggle()
            } label: {
                HStack(spacing: 6) {
                    Text(selection.description)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .pointerStyle(.link)
            .popover(isPresented: $isPresented, arrowEdge: .bottom) {
                Picker("Click Sample", selection: $selection) {
                    ForEach(ClickSample.allCases) { option in
                        Text(option.description).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
                .padding()
                .onChange(of: selection) {
                    isPresented = false
                }
            }
        }
    }
}
