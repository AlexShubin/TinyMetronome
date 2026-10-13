//
//  ScrollWheelModifier.swift
//  TinyMetronome
//
//  Created by Alex Shubin on 13.10.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AppKit
import SwiftUI

private struct ScrollWheelModifier: ViewModifier {
    let pointsPerNotch: CGFloat
    let action: (CGFloat) -> Void

    @State private var isHovered = false
    @State private var monitor: Any?

    func body(content: Content) -> some View {
        content
            .onHover { isHovered = $0 }
            .onAppear {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    guard isHovered, event.momentumPhase.isEmpty, event.upwardScrollingDeltaY != 0 else { return event }
                    action(event.upwardScrollDistance(pointsPerNotch: pointsPerNotch))
                    return nil
                }
            }
            .onDisappear {
                NSEvent.removeMonitor(monitor!)
            }
    }
}

extension View {
    /// Vertical scrolling over the view in points, fingers-up positive. Momentum is ignored.
    func onScrollWheel(pointsPerNotch: CGFloat, action: @escaping (CGFloat) -> Void) -> some View {
        modifier(ScrollWheelModifier(pointsPerNotch: pointsPerNotch, action: action))
    }
}

private extension NSEvent {
    var upwardScrollingDeltaY: CGFloat {
        isDirectionInvertedFromDevice ? -scrollingDeltaY : scrollingDeltaY
    }

    func upwardScrollDistance(pointsPerNotch: CGFloat) -> CGFloat {
        if hasPreciseScrollingDeltas { return upwardScrollingDeltaY }
        return upwardScrollingDeltaY > 0 ? pointsPerNotch : -pointsPerNotch
    }
}
